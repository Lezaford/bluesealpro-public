class ScheduleController < ApplicationController
  before_action :authenticate_user!
  before_action :set_date
  before_action :set_technicians
  before_action :set_jobs

  def index
    @hours = (6..18).to_a  # 6am to 6pm
    @assigned_jobs = @jobs.where.not(technician_id: nil).includes(:technician).group_by(&:technician_id)
    @unassigned_jobs = @jobs.where(technician_id: nil).order(:customer_id)
  end

  private

  def set_date
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def set_technicians
    @technicians = Current.company.technicians.active.order(:name)
  end

  def set_jobs
    @jobs = Current.company.jobs.on_date(@date).includes(:technician, :customer)
  end
end
