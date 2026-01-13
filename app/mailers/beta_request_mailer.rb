class BetaRequestMailer < ApplicationMailer
  default to: "betarequest@example.com", from: "noreply@example.com"

  def new_request(beta_request)
    @beta_request = beta_request
    mail(
      subject: "New BlueSealPro Beta Request from #{@beta_request.name} (#{@beta_request.company})"
    )
  end
end
