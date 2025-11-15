class BetaRequest < ApplicationRecord
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false, message: "has already been submitted for beta access." }

  validate :email_not_registered

  private

  def email_not_registered
    if User.exists?(email: email)
      errors.add(:email, "already belongs to an active account.")
    end
  end
end
