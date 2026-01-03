class LineItem < ApplicationRecord
  belongs_to :invoice

  validates :invoice_id, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :item_type, presence: true, inclusion: { in: %w[labor materials discount tax] }
  validates :description, presence: true
end
