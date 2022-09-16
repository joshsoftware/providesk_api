class Ticket < ApplicationRecord
  include AASM

  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department
  belongs_to :category
  has_many :activities

  enum status: {
    "assigned": 0,
    "inprogress": 1,
    "resolved": 2,
    "closed": 3,
    "rejected": 4
  }

  enum priority: {
    "regular": 0,
    "high": 1,
    "medium": 2,
    "low": 3
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
      transitions from: :assigned, to: :rejected
    end

    event :resolve do
      transitions from: :inprogress, to: :resolved
    end

    event :close do
      transitions from: :resolve, to: :closed
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
end
