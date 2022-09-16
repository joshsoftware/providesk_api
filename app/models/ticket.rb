class Ticket < ApplicationRecord
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

  enum type: {
    "complaint": 0,
    "request": 1
  }

  belongs_to :resolver, :class_name => 'User', :foreign_key => 'resolver_id'
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :department
  belongs_to :category
end