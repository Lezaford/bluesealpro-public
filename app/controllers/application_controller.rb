class ApplicationController < ActionController::Base
  before_action :set_current_company
  before_action :check_password_change_required, if: :user_signed_in?
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

  def check_password_change_required
    # Redirect to password change if user hasn't changed password yet
    # Skip for password change controller and logout
    if current_user&.password_change_required? && !request.path.start_with?("/password_change")
      redirect_to password_change_path unless request.path == "/"
    end
  end

  # Redirect to dashboard after sign in
  def after_sign_in_path_for(resource)
    if resource.password_change_required?
      password_change_path
    else
      dashboard_path
    end
  end

  # lets Devise accept :name now; you can add more later
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
