class Company < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :technicians, dependent: :restrict_with_error
  has_many :jobs, dependent: :restrict_with_error
  has_many :invoices, dependent: :restrict_with_error
  has_many :price_book_items, dependent: :restrict_with_error
  has_one_attached :logo

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :logo, content_type: { with: %w[image/png image/jpeg image/gif], message: "must be an image" }, size: { less_than: 5.megabytes, message: "must be less than 5 MB" }, if: :logo_attached?

  private

  def logo_attached?
    logo.attached?
  end
end
