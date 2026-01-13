class LineItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :company
  belongs_to :price_book_item, optional: true

  enum :category, { service: "service", labor: "labor", materials: "materials", discount: "discount" }

  validates :invoice_id, presence: true
  validates :company_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :category, presence: true, inclusion: { in: categories.keys }
  validates :description, presence: true
  validate :company_matches_invoice

  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
  scope :unlocked, -> { where(locked: false) }
  scope :locked, -> { where(locked: true) }

  def total_cents
    (quantity * unit_price_cents).to_i
  end

  def taxable_total_cents
    taxable? ? total_cents : 0
  end

  private

  def company_matches_invoice
    return if invoice.blank? || company.blank?
    errors.add(:company, "must match invoice's company") if invoice.company_id != company_id
  end
end
