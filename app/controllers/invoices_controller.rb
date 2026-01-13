class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_job, only: [ :show, :new, :create ]

  def index
    @invoices = Current.company.invoices.order(created_at: :desc)
  end

  def show
    @invoice = @job.invoice || not_found
  end

  def new
    if @job.invoice.present?
      redirect_to job_invoice_path(@job), alert: "Invoice already exists for this job."
      nil
    end
  end

  def create
    if @job.invoice.present?
      redirect_to job_invoice_path(@job), alert: "Invoice already exists for this job."
      return
    end

    @invoice = Invoice.new(company: Current.company, job: @job)
    if @invoice.save
      redirect_to job_invoice_path(@job), notice: "Invoice created successfully."
    else
      redirect_to job_path(@job), alert: "Failed to create invoice: #{@invoice.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_job
    @job = Current.company.jobs.find(params[:job_id])
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
