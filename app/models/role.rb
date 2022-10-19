class Role < ApplicationRecord
  has_many :users, dependent: :destroy

  validates_associated :users
  validates :name, presence: true, uniqueness: true

  before_validation :change_case_name, only: [:create, :update]

  ROLE = { super_admin: "super_admin", admin: "admin" }
end
