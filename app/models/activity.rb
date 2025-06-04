class Activity < ApplicationRecord
  belongs_to :ticket

  validates :assigned_from, presence: true
  validates :assigned_to, presence: true
  validates :description, presence: true

  enum current_ticket_status: Ticket.statuses, _prefix: :current_status
  enum previous_ticket_status: Ticket.statuses, _prefix: :previous_status
end
