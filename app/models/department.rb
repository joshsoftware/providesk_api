class Department < ApplicationRecord
  has_one :organization
  has_many :categories
  has_many :users

  validates :name, uniqueness: true
end
