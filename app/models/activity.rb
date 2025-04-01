class Activity < ApplicationRecord
  belongs_to :ticket

  validates :assigned_from, presence: true
  validates :assigned_to, presence: true
  validates :description, presence: true
  validates :current_ticket_status, inclusion: { in: ["assigned", "inprogress", "for_approval", "closed", "rejected", "on_hold"] }
  validates :previous_ticket_status, inclusion: { in: ["assigned", "inprogress", "for_approval", "closed", "rejected", "on_hold"] }

  enum current_ticket_status: Ticket.statuses, _prefix: :current_status
  enum previous_ticket_status: Ticket.statuses, _prefix: :previous_status
end
