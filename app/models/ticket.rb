class Ticket < ApplicationRecord
  include AASM
  audited only: [:resolver_id, :department_id, :category_id, :status], on: [:update]

  has_many :activities
  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department, :class_name => 'Department', :foreign_key => 'department_id'
  belongs_to :category

  # before_validation :downcase_ticket_type, only: [:create, :update]
  after_save :create_activity

  validates_associated :activities
  validates :title, presence: true
  validates :description, presence: true
  validates :ticket_type, presence: true
  #validates :ticket_number, presence: true

  enum status: {
    "assigned": 0,
    "inprogress": 1,
    "for_approval": 2,
    "resolved": 3,
    "closed": 4,
    "rejected": 5
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

    after_all_events :send_notification

    event :start do
      transitions from: [:assigned, :for_approval], to: :inprogress
    end

    event :approve do 
      transitions from: :assigned, to: :for_approval
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
  end

  def send_notification
    description = I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, 
                         requester: requester.name, department: department.name)
    NotifyMailer.notify_status_change(resolver, requester, description, id).deliver_now
  end

  def create_activity
    activity_attr = {current_ticket_status: status, ticket_id: id, 
                     description: get_description_of_update, reason_for_update: reason_for_update}
    if @previous_resolver != @new_resolver
      activity_attr.merge!(assigned_from: @previous_resolver, assigned_to: @new_resolver)
    else
      activity_attr.merge!(assigned_from: resolver.name, assigned_to: resolver.name)
    end
    Activity.create!(activity_attr)
  end

  def get_description_of_update
    if Audited::Audit.where(auditable_id: self.id) == []
      message = I18n.t('ticket.description.new_ticket', id: id)
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
          message.append(I18n.t('ticket.description.department'), previous_department: previous_department, 
                        new_department: new_department)
        end
      end
    end
    message
  end

  def downcase_ticket_type
    self.ticket_type.downcase!
  end
end
