class Activity < ApplicationRecord
  
  enum :current_status {
    "assigned": 0,
    "inprogress": 1,
    "resolved": 2,
    "closed": 3,
    "rejected": 4
  }
end
