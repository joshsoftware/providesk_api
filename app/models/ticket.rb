class Ticket < ApplicationRecord
  include AASM
  attr_accessor :attribute_changed, :ticket_created, :asset_url_on_update
  audited only: [:resolver_id, :department_id, :category_id, :status, :asset_url, :eta, :ticket_type, :title, :description], on: [:update]

  after_create :set_ticket_number_and_eta, :send_notification, :create_activity

  has_many :activities
  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department, :class_name => 'Department', :foreign_key => 'department_id'
  belongs_to :category

  before_save :status_or_resolver_or_department_or_category_or_asset_url_changed?
  after_save :create_activity, if: :attribute_changed, unless: :ticket_created
  validates_associated :activities
  validates :title, presence: true
  validates :description, presence: true
  validates :ticket_type, presence: true
  #validates :ticket_number, presence: true

  ASK_FOR_UPDATE = false
  ESCALATE_STATUS = { "assigned": 1, "for_approval": 2, "inprogress": 3, "resolved": 2, "on_hold": 3} # Time in days

  enum status: {
    "assigned": 0,
    "inprogress": 1,
    "for_approval": 2,
    "resolved": 3,
    "closed": 4,
    "rejected": 5,
    "on_hold": 6
  }

  enum priority: {
    "Regular": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3
  }

  enum ticket_type: {
    "Complaint": 0,
    "Request": 1
  }

  aasm column: :status, whiny_persistence: true do
    state :assigned, initial: true
    state :inprogress
    state :for_approval
    state :resolved
    state :closed
    state :rejected
    state :on_hold

    after_all_events :send_notification

    event :start do
      transitions from: [:assigned, :for_approval, :on_hold], to: :inprogress
    end

    event :approve do 
      transitions from: [:assigned, :on_hold], to: :for_approval
    end

    event :reject do
      transitions from: [:assigned, :for_approval], to: :rejected
    end

    event :resolve do
      transitions from: :inprogress, to: :resolved
    end

    event :close do
      transitions from: :resolved, to: :closed
    end

    event :reopen do
      transitions from: :resolved, to: :for_approval
    end

    event :hold do
      transitions from: [:assigned, :inprogress, :for_approval], to: :on_hold
    end

    event :activate do
      transitions from: :on_hold, to: :assigned
    end
  end

  def status_or_resolver_or_department_or_category_or_asset_url_changed?
    @attribute_changed = (status_changed? || resolver_id_changed? || department_id_changed? || 
                          category_id_changed? || asset_url_changed? || title_changed? || 
                          description_changed? || ticket_type_changed? || eta_changed?) ? true : false
    if asset_url.blank? || !asset_url_changed?
      @asset_url_on_update = []
    elsif asset_url_changed?
      @asset_url_on_update = asset_url_change.last - asset_url_change.first
    end
  end

  def send_notification
    description = I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, 
                         requester: requester.name, department: department.name)
    NotifyMailer.notify_status_change(resolver, requester, description, id).deliver_now
  end

  def set_ticket_number_and_eta
    ticket_number = ticket_type + "-" + id.to_s
    sla_duration_in_hours = Category.find(category_id).duration_in_hours
    eta = Date.today + (sla_duration_in_hours/24).to_i.days
    Ticket.find(id).update(ticket_number: ticket_number, eta: eta)
    @ticket_created = true
  end
  
  def send_email_to_department_head
    department_head_id = Role.find_by(name: "department_head").id
    department_head = User.find_by(department_id: department_id, role_id: department_head_id)
    if !department_head
      department_head = User.find_by(role_id: Role.find_by(name: "admin").id, organization_id: self.organization_id)
    end
    description = I18n.t('ticket.description.ticket_escalation', id: id)
    NotifyMailer.notify_status_escalate(department_head, requester, description, id).deliver_now
  end

  def send_email_to_resolver(ticket_link)
    NotifyMailer.notify_status_update(resolver, requester, id, ticket_link).deliver_now
  end

  def create_activity
    activity_attr = {current_ticket_status: status, ticket_id: id, asset_url: asset_url_on_update,
                     description: get_description_of_update, reason_for_update: reason_for_update}
    if @previous_status
      activity_attr.merge!(previous_ticket_status: @previous_status)
    else 
      activity_attr.merge!(previous_ticket_status: status)
    end

    if @previous_resolver != @new_resolver
      activity_attr.merge!(assigned_from: @previous_resolver, assigned_to: @new_resolver)
    else
      activity_attr.merge!(assigned_from: resolver.name, assigned_to: resolver.name)
    end
    Activity.create!(activity_attr)
  end

  def get_description_of_update
    if Audited::Audit.where(auditable_id: self.id) == []
      message = [I18n.t('ticket.description.new_ticket', id: id)]
    else
      changes = Audited::Audit.where(auditable_id: self.id).order(:created_at).pluck(:audited_changes).last
      message = []
      changes.each do |key, val|
        case key
        when "category_id"
          previous_category = Category.where(id: val[0]).pluck(:name)[0]
          new_category = Category.where(id: val[1]).pluck(:name)[0]
          message.append(I18n.t('ticket.description.category', previous_category: previous_category, new_category: new_category))
        when "status"
          @previous_status = Ticket.statuses.key(val[0])
          message.append(I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, 
                        requester: requester.name, department: department.name))
        when "resolver_id"
          @previous_resolver = User.where(id: val[0]).pluck(:name)[0]
          @new_resolver = User.where(id: val[1]).pluck(:name)[0]
          message.append(I18n.t('ticket.description.resolver', previous_resolver: @previous_resolver, new_resolver: @new_resolver))
        when "department_id"
          previous_department = Department.where(id: val[0]).pluck(:name)[0]
          new_department = Department.where(id: val[1]).pluck(:name)[0]
          message.append(I18n.t('ticket.description.department', previous_department: previous_department, 
                        new_department: new_department))
        when "asset_url"
          message.append(I18n.t('ticket.description.asset_url'))
        when "eta"
          message.append(I18n.t('ticket.description.eta'))
        when "ticket_type"
          previous_type, new_type = Ticket.ticket_types.key(val[0]), Ticket.ticket_types.key(val[1])
          message.append(I18n.t('ticket.description.ticket_type', previous_type: previous_type, new_type: new_type))
        when "title"
          message.append(I18n.t('ticket.description.title'))
        when "description"
          message.append(I18n.t('ticket.description.description'))
        end
      end
    end
    message
  end

  def downcase_ticket_type
    self.ticket_type.downcase!
  end
end
