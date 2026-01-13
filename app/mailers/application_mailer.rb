class ApplicationMailer < ActionMailer::Base
  default from: "noreply@example.com"
  layout "mailer"

  protected

  # Helper to get company-specific from address or fallback
  def company_from_address(resource)
    if resource.respond_to?(:company) && resource.company&.email.present?
      resource.company.email
    else
      "noreply@example.com"
    end
  end
end
