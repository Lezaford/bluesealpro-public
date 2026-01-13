class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  def mail(headers = nil, &block)
    # Add company-specific from address or fallback to noreply@example.com
    if resource.respond_to?(:company) && resource.company&.email.present?
      headers = (headers || {}).merge(from: resource.company.email)
    else
      headers = (headers || {}).merge(from: "noreply@example.com")
    end
    super(headers, &block)
  end
end
