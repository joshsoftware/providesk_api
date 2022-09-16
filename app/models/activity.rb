class Activity < ApplicationRecord
  belongs_to :ticket

  validates :assigned_from, presence: true
  validates :assigned_to, presence: true
  validates :description, presence: true
  validates :current_status, inclusion: { in: ["assigned", "inprogress", "resolved", "closed", "resolved"] }

  enum current_ticket_status: {
    "assigned": 0,
    "inprogress": 1,
    "resolved": 2,
    "closed": 3,
    "rejected": 4
  }
end
