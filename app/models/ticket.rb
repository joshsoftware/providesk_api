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
      transitions from: :assigned, to: :rejected
    end

    event :resolve do
      transitions from: :inprogress, to: :resolved
    end

    event :close do
      transitions from: :resolve, to: :closed
    end
  end

  scope :of_status, ->(status) { where(status: status) }

  def add_activity
    Activity.create( assigned_from: "", assigned_to: "", current_ticket_status: status, ticket_id: id, 
                     description: I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
                   )
  end

  def send_notification
    description = I18n.t("ticket.#{status}", ticket_type: ticket_type, resolver: resolver.name, requester: requester.name)
    NotifyMailer.notify_status_change(resolver, requester, description, id).deliver_now
  end

  def listing_data_attributes
    self.as_json(
      only: [:id, :status, :title, :description, :ticket_number, :ticket_type, :priority, :created_at, :resolved_at],
      methods: [:department_name, :category_name, :resolver_name]
    )
  end

  def department_name
    self&.department&.name
  end

  def category_name
    self&.category&.name
  end

  def resolver_name
    self&.resolver&.name
  end
end
