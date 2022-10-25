class Ticket < ApplicationRecord
  include AASM

  has_many :activities
  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department
  belongs_to :category

  before_validation :downcase_ticket_type, only: [:create, :update]

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
    "complaint": 0,
    "request": 1
  }

  aasm column: :status, whiny_persistence: true do
    state :assigned, initial: true
    state :inprogress
    state :for_approval
    state :resolved
    state :closed
    state :rejected

    after_all_events :add_activity, :send_notification

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

  def add_activity
    Activity.create( assigned_from: resolver.name, assigned_to: resolver.name, current_ticket_status: status, ticket_id: id, 
                     description: I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
                   )
  end

  def send_notification
    description = I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
    NotifyMailer.notify_status_change(resolver, requester, description, id).deliver_now
  end

  def downcase_ticket_type
    self.ticket_type.downcase!
  end
end