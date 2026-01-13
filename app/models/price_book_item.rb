class PriceBookItem < ApplicationRecord
  belongs_to :company
  has_many :line_items, dependent: :nullify

  enum :category, { service: "service", labor: "labor", materials: "materials", discount: "discount" }
  enum :lock_policy, { admin_only: "admin_only", tech_editable: "tech_editable" }

  validates :company_id, presence: true
  validates :name, presence: true
  validates :unit_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :category, presence: true, inclusion: { in: categories.keys }

  scope :active, -> { where(active: true) }
  scope :by_category, ->(cat) { where(category: cat) if cat.present? }
end
