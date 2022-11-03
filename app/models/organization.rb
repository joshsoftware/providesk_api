class Organization < ApplicationRecord
  has_many :departments, dependent: :destroy
  has_many :users, dependent: :destroy

  before_validation :change_case_name, only: [:create, :update], if: :name?

  validates_associated :departments
  validates_associated :users
  validates :name, presence: true, uniqueness: true
end
