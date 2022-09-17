class User < ApplicationRecord
  belongs_to :organization, optional: true
  belongs_to :role
  belongs_to :department, optional: true
  has_many :tickets

  validates :name, presence: true
  validates :email,presence: true, uniqueness: true
  validates_assocaited :tickets

end