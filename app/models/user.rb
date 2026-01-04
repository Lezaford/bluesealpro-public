class User < ApplicationRecord
  # Devise modules (add others later if you want)
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  belongs_to :company, optional: false
  has_one :technician, dependent: :nullify

  enum :role, { owner: 0, admin: 1, tech: 2, viewer: 3 }, prefix: true

  validates :name, presence: true
end
