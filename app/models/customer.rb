class Customer < ApplicationRecord
  belongs_to :company
  has_many :jobs, dependent: :restrict_with_error # when you add jobs

  validates :first_name, :last_name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
