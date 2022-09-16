class Category < ApplicationRecord
  belongs_to :department

  enum priority: {
    "Regular": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3
  }
end
