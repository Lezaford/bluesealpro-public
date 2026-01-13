class Invoice < ApplicationRecord
  belongs_to :company
  belongs_to :job
  has_many :line_items, dependent: :destroy

  validates :job_id, presence: true, uniqueness: true
  validate :job_matches_company

  def subtotal_cents
    line_items.sum { |li| li.category == "discount" ? -li.total_cents : li.total_cents }
  end

  def taxable_subtotal_cents
    line_items.sum { |li| li.taxable? && li.category != "discount" ? li.total_cents : 0 }
  end

  def discount_total_cents
    line_items.where(category: "discount").sum(&:total_cents)
  end

  def tax_cents
    (taxable_subtotal_cents * company.tax_rate).round
  end

  def total_cents
    subtotal_cents + tax_cents
  end

  def subtotal_dollars
    subtotal_cents / 100.0
  end

  def tax_dollars
    tax_cents / 100.0
  end

  def total_dollars
    total_cents / 100.0
  end

  private

  def job_matches_company
    return if job.blank? || company.blank?
    errors.add(:job, "must belong to the same company") if job.company_id != company_id
  end
end
