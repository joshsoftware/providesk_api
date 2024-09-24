class Category < ApplicationRecord
  belongs_to :department

  has_many :user_categories, dependent: :destroy
  has_many :users, through: :user_categories

  validates :name, uniqueness: { scope: :department }, presence: true
  validates :priority, inclusion: { in: ["Regular", "High", "Medium", "Low"] }

  # before_validation :change_case_name, only: [:create, :update], if: :name?

  enum priority: {
    "Regular": 0,
    "High": 1,
    "Medium": 2,
    "Low": 3
  }
end
