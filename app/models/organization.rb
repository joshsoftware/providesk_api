class Organization < ApplicationRecord
  has_many :departments
  has_many :users
end
