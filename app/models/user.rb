class User < ApplicationRecord
  belongs_to :organization
  belongs_to :role
  belongs_to :department

  validates :email, uniqueness: true
end