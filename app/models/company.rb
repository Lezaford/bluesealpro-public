class Company < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :technicians, dependent: :restrict_with_error
  has_many :jobs, dependent: :restrict_with_error
  has_many :invoices, dependent: :restrict_with_error

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
end
