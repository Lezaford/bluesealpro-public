class Job < ApplicationRecord
  belongs_to :company
  belongs_to :customer
  belongs_to :technician, optional: true
  has_one :invoice, dependent: :destroy
  has_many :line_items, through: :invoice

  validates :customer_id, presence: true
  validates :notes, presence: true

  scope :by_technician, ->(technician) { where(technician: technician) }
  scope :on_date, ->(date) { where("DATE(starts_at) = ?", date) }
end
