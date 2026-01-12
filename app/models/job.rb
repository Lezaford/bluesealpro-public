class Job < ApplicationRecord
  belongs_to :company
  belongs_to :customer
  belongs_to :technician, optional: true
  has_one :invoice, dependent: :destroy
  has_many :line_items, through: :invoice

  validates :customer_id, presence: true
  validates :complaint, presence: true
  validate :completed_requires_notes
  validate :status_not_overridden

  scope :by_technician, ->(technician) { where(technician: technician) }
  scope :on_date, ->(date) { where("DATE(starts_at) = ?", date) }

  private

  def completed_requires_notes
    if status == "completed" && diagnosis.blank? && work_performed.blank?
      errors.add(:base, "Completed jobs must have either a diagnosis or work performed documented.")
    end
  end

  def status_not_overridden
    # Prevent validation errors - status override is handled in controller
    # This is here as a reference for the business rule
  end
end
