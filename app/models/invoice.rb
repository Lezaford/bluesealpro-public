class Invoice < ApplicationRecord
  belongs_to :company
  belongs_to :job
  has_many :line_items, dependent: :destroy

  validates :job_id, presence: true, uniqueness: true
  validate :job_matches_company

  private

  def job_matches_company
    return if job.blank? || company.blank?
    errors.add(:job, "must belong to the same company") if job.company_id != company_id
  end
end
