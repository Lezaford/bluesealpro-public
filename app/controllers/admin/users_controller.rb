class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :edit, :update ]

  def index
    @users = current_company.users.order(:name)
  end

  def edit
    # @user is set by before_action
  end

  def update
    # @user is set by before_action
    if params[:user][:role].present? || params[:user][:active].present?
      # Check for guard condition: cannot remove last privileged user
      if cannot_change_privilege?(@user, params[:user])
        @user.errors.add(:base, "Cannot change the last owner/admin in this company.")
        render :edit
        return
      end
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  private

  def set_user
    @user = current_company.users.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role, :active)
  end

  def cannot_change_privilege?(_user, new_params)
    # If the user is currently privileged (owner or admin) and the update would make them not privileged,
    # check if there's at least one other active privileged user
    user_is_privileged = _user.role_owner? || _user.role_admin?
    new_role = new_params[:role].presence || _user.role
    new_active = new_params[:active].present? ? new_params[:active] == "1" : _user.active?

    new_is_privileged = new_role.in?(%w[owner admin])

    return false unless user_is_privileged && (!new_is_privileged || !new_active)

    # Count other active privileged users in the company
    other_privileged = current_company.users
      .where(active: true)
      .where(role: [ :owner, :admin ])
      .where.not(id: _user.id)
      .count

    other_privileged.zero?
  end
end
