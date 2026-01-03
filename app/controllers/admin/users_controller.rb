class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = Current.company.users.order(:email)
  end

  def new
    @user = Current.company.users.build
  end

  def create
    @user = Current.company.users.build(user_params)

    if @user.save
      redirect_to admin_users_url, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_url, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_url, notice: "User was successfully deleted."
  end

  private

  def set_user
    @user = Current.company.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :role, :password, :password_confirmation)
  end

  def authorize_admin!
    redirect_to dashboard_path, alert: "Not authorized" unless current_user.role_owner? || current_user.role_admin?
  end
end
