class ScheduleController < ApplicationController
  before_action :set_date
  before_action :set_technicians
  before_action :set_jobs

  def index
    @hours = (6..18).to_a  # 6am to 6pm (18:00)
    @schedule = build_schedule
  end

  private

  def set_date
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
  end

  def set_technicians
    @technicians = Current.company.technicians.active.by_name
  end

  def set_jobs
    @jobs = Current.company.jobs.on_date(@date).includes(:technician, :customer)
  end

  def build_schedule
    schedule = {}
    @technicians.each do |tech|
      schedule[tech.id] = {}
      @hours.each do |hour|
        schedule[tech.id][hour] = []
      end
    end

    @jobs.each do |job|
      next unless job.technician && job.starts_at

      start_hour = job.starts_at.hour
      if @hours.include?(start_hour)
        schedule[job.technician_id][start_hour] << job
      end
    end

    schedule
  end
end
