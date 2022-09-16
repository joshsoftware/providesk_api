class Category < ApplicationRecord
  belongs_to :department

  validates :name, presence: true
  validates :priority, inclusion: { in: ["Regular", "High", "Medium", "Low"] }
  
  enum priority: {
    "Regular": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3
  }
end
