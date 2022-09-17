class Role < ApplicationRecord
  has_many :users, dependent: :destroy

  validates_associated :users
  validates :name, presence: true, uniqueness: true
end
