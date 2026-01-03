class Invoice < ApplicationRecord
  belongs_to :company
  belongs_to :job
  has_many :line_items, dependent: :destroy

  validates :job_id, presence: true
end
