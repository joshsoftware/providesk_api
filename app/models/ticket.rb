class Ticket < ApplicationRecord
  include AASM

  has_many :activities
  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department
  belongs_to :category

  validates_associated :activities
  validates :title, presence: true
  validates :description, presence: true
  validates :ticket_type, presence: true

  after_save :create_activity

  enum status: {
    "assigned": 0,
    "inprogress": 1,
    "resolved": 2,
    "closed": 3,
    "rejected": 4
  }

  enum priority: {
    "Regular": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3
  }

  enum ticket_type: {
    "complaint": 0,
    "request": 1
  }

  aasm column: :status, whiny_persistence: true do
    state :assigned, initial: true
    state :inprogress
    state :resolved
    state :closed
    state :rejected

    after_all_events :add_activity, :send_notification

    event :start do
      transitions from: :assigned, to: :inprogress
    end

    event :reject do
      transitions from: [:assigned, :inprogress], to: :rejected
    end

    event :resolve do
      transitions from: [:assigned, :inprogress], to: :resolved
    end

    event :close do
      transitions from: [:assigned, :inprogress, :resolve], to: :closed
    end
  end

  def add_activity
    Activity.create( assigned_from: "", assigned_to: "", current_ticket_status: status, ticket_id: id, 
                     description: I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
                   )
  end

  def send_notification
    description = I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
    NotifyMailer.notify_status_change(resolver, requester, description, id).deliver_now
  end

  def set_status(update_params[:status])
    status = update_params[:status]
    case status
    when 'inprogress'
      self.start!
    when 'resolved'
      self.resolve!
    when 'closed'
      self.close!
    when 'rejected'
      self.reject!
    end
  end

  def create_activity
    activity_attr = {current_ticket_status: status, ticket_id: id,
                     description: I18n.t("ticket.#{status}"), ticket_type: ticket_type, resolver: resolver.name,
                     requester: requester.name}
    if self.resolver_changed?
      activity_attr.merge!(assigned_from: self.resolver_was.id, assigned_to: self.resolver.id)
    else
      activity_attr.merge!(assigned_from: "", assigned_to: "")
    end
    Activity.create(activity_attr)
  end
end
