class JobsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [ :show, :edit, :update, :destroy ]

  # GET /jobs
  def index
    @query = params[:q].to_s.strip
    @status = params[:status].to_s.strip

    # options for dropdowns
    base = Current.company.jobs
    @statuses = base.where.not(status: nil).distinct.pluck(:status).compact_blank.sort

    scope = base_scope
    @jobs = scope.order(starts_at: :desc)
  end

  # GET /jobs/:id
  def show
  end

  # GET /jobs/new
  def new
    @job = Current.company.jobs.new
    @job.status ||= "pending"
    @job.starts_at ||= next_30_min_block_in_local_tz
    @technicians = Current.company.technicians.where(active: true).order(:name)
  end

  # GET /jobs/:id/edit
  def edit
    @technicians = Current.company.technicians.where(active: true).order(:name)
  end

  # POST /jobs
  def create
    @job = Current.company.jobs.new(job_params)

    # Validate customer belongs to current company
    if @job.customer_id.present?
      unless Current.company.customers.exists?(@job.customer_id)
        @job.errors.add(:customer, "must belong to your company")
        @technicians = Current.company.technicians.where(active: true).order(:name)
        flash.now[:alert] = @job.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
        return
      end
    end

    apply_status_rule(@job)
    if @job.save
      redirect_target = params[:commit_action] == "save_new" ? new_job_path : @job
      notice = params[:commit_action] == "save_new" ? "Job created. Create another?" : "Job was created."
      redirect_to redirect_target, notice: notice
    else
      @technicians = Current.company.technicians.where(active: true).order(:name)
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/:id
  def update
    # Validate customer belongs to current company
    if job_params[:customer_id].present?
      unless Current.company.customers.exists?(job_params[:customer_id])
        @job.errors.add(:customer, "must belong to your company")
        @technicians = Current.company.technicians.where(active: true).order(:name)
        flash.now[:alert] = @job.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
        return
      end
    end

    apply_status_rule(@job)
    if @job.update(job_params)
      redirect_target = params[:commit_action] == "save_new" ? new_job_path : @job
      notice = params[:commit_action] == "save_new" ? "Job updated. Create another?" : "Job was updated."
      redirect_to redirect_target, notice: notice
    else
      @technicians = Current.company.technicians.where(active: true).order(:name)
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /jobs/:id
  def destroy
    @job.destroy
    redirect_to jobs_path, notice: "Job was deleted."
  end

  private

  def set_job
    @job = Current.company.jobs.find(params[:id])
  end

  def base_scope
    scope = Current.company.jobs

    if params[:q].present?
      q = "%#{params[:q].strip.downcase}%"
      scope = scope.joins(:customer)
        .where(
          "LOWER(customers.first_name) LIKE :q OR LOWER(customers.last_name) LIKE :q OR " \
          "LOWER(jobs.model_number) LIKE :q OR LOWER(jobs.serial_number) LIKE :q OR " \
          "LOWER(jobs.status) LIKE :q",
          q: q
        )
    end

    if params[:status].present?
      scope = scope.where(status: params[:status])
    end

    scope
  end

  def job_params
    params.require(:job).permit(
      :customer_id,
      :technician_id,
      :status,
      :starts_at,
      :complaint,
      :diagnosis,
      :work_performed,
      :model_number,
      :serial_number,
      :notes,
      :appliance_type,
      :brand
    )
  end

  def next_30_min_block_in_local_tz
    now = Time.current.in_time_zone(Current.user.timezone || "UTC")
    minutes_past = now.min
    minutes_to_next_block = (30 - (minutes_past % 30)) % 30
    next_block = minutes_to_next_block.zero? ? now : now + (minutes_to_next_block * 60).seconds
    next_block.beginning_of_minute
  end

  def apply_status_rule(job)
    # If technician is assigned and status is blank or pending, set to in_progress
    if job.technician_id.present? && (job.status.blank? || job.status == "pending")
      job.status = "in_progress"
    end
  end
end
