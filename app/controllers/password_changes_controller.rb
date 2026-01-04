class PasswordChangesController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to dashboard_path unless current_user.password_change_required?
  end

  def update
    if current_user.update_with_password(password_change_params)
      current_user.update(password_change_required: false)
      redirect_to dashboard_path, notice: "Password changed successfully. Welcome!"
    else
      @user = current_user
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_change_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end
