class Role < ApplicationRecord
  has_many :users, dependent: :destroy

  validates_associated :users
  validates :name, presence: true, uniqueness: true

  ROLE = { super_admin: "super_admin", admin: "admin", employee: "employee"}
end
