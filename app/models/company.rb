class Company < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
