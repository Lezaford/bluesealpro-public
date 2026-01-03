class ApplicationController < ActionController::Base
  before_action :set_current_company
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_company

  private

  def set_current_company
    return unless user_signed_in?
    Current.user    = current_user
    Current.company = current_user.company
  end

  def current_company
    Current.company
  end

  # Redirect to dashboard after sign in
  def after_sign_in_path_for(resource)
    dashboard_path
  end

  # lets Devise accept :name now; you can add more later
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
