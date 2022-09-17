class Department < ApplicationRecord
  belongs_to :organization
  has_many :categories, dependent: :destroy
  has_many :users, dependent: :destroy

  validates_associated :categories
  validates_associated :users
  validates_presence_of :organization
  validates :name, presence: true, uniqueness: { scope: :organization }
end
