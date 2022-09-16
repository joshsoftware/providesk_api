class Department < ApplicationRecord
  has_one :organization
  has_many :categories
end
