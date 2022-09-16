class Organization < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :users, dependent: :destroy

  validates_associated :departments
  validates_associated :users
  validates :name, presence: true
end
