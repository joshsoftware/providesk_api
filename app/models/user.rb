class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :role, optional: true
  belongs_to :department, optional: true

  validates :email, uniqueness: true
end