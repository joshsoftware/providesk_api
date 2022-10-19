class Activity < ApplicationRecord
  belongs_to :ticket

  validates :assigned_from, presence: true
  validates :assigned_to, presence: true
  validates :description, presence: true
  validates :current_ticket_status, inclusion: { in: ["assigned", "inprogress", "for_approval", "resolved", "closed", "rejected"] }

  enum current_ticket_status: {
    "assigned": 0,
    "inprogress": 1,
    "for_approval": 2,
    "resolved": 3,
    "closed": 4,
    "rejected": 5
  }
end
