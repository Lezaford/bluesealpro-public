class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Standard dashboard for non-admin users
  end
end
