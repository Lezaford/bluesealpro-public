class TechnicianMailer < ApplicationMailer
  default from: "noreply@example.com"

  def welcome_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password
    @company = user.company

    mail(
      to: user.email,
      subject: "Welcome to BlueSealPro - Your Account is Ready"
    )
  end
end
