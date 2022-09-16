class User < ApplicationRecord
  belongs_to :organization
  belongs_to :role

  validates :email , uniqueness: true
end