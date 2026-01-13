class ApplicationController < ActionController::Base
  before_action :set_current_company
  before_action :check_password_change_required, if: :user_signed_in?
  before_action :check_user_active, if: :user_signed_in?
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

  def check_user_active
    # Sign out inactive users
    if !current_user.active?
      sign_out current_user
      redirect_to root_path, alert: "Your account has been deactivated."
    end
  end

  def require_admin!
    redirect_to dashboard_path, alert: "Access denied." unless current_user.role_owner? || current_user.role_admin?
  end

  def require_staff!
    redirect_to dashboard_path, alert: "Access denied." unless current_user.role_owner? || current_user.role_admin? || current_user.role_tech?
  end

  # Redirect to dashboard after sign in
  def after_sign_in_path_for(resource)
    if resource.password_change_required?
      password_change_path
    elsif resource.role_owner? || resource.role_admin?
      admin_dashboard_path
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
