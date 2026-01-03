class Technician < ApplicationRecord
  belongs_to :company
  has_many :jobs, dependent: :restrict_with_error

  validates :name, presence: true
  validates :phone, presence: true
  validates :company_id, presence: true

  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }
end
