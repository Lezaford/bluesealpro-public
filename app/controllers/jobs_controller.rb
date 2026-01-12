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
    @customers = Current.company.customers.order(:last_name, :first_name)
    @technicians = Current.company.technicians.where(active: true).order(:name)
  end

  # GET /jobs/:id/edit
  def edit
    @customers = Current.company.customers.order(:last_name, :first_name)
    @technicians = Current.company.technicians.where(active: true).order(:name)
  end

  # POST /jobs
  def create
    @job = Current.company.jobs.new(job_params)
    if @job.save
      redirect_to @job, notice: "Job was created."
    else
      @customers = Current.company.customers.order(:last_name, :first_name)
      @technicians = Current.company.technicians.where(active: true).order(:name)
      flash.now[:alert] = @job.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /jobs/:id
  def update
    if @job.update(job_params)
      redirect_to @job, notice: "Job was updated."
    else
      @customers = Current.company.customers.order(:last_name, :first_name)
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
      :notes
    )
  end
end
