class BetaRequestMailer < ApplicationMailer
  default to: "betarequest@example.com"  # <-- YOUR email here

  def new_request(beta_request)
    @beta_request = beta_request
    mail(
      subject: "New BlueSealPro Beta Request from #{beta_request.name}",
      from: beta_request.email.presence || "noreply@example.com"
    )
  end
end
