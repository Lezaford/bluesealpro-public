class InvoicesController < ApplicationController
  before_action :authenticate_user!
  def index
    @invoices = Invoice.where(company_id: current_user.company_id).order(created_at: :desc)
  end
  def show
    @invoice = Invoice.find(params[:id])
    authorize_company!(@invoice.company_id)
  end
  def create
    # stub: create via Jobs#invoices nested later
  end
  private
  def authorize_company!(company_id)
    head :forbidden unless company_id == current_user.company_id
  end
end
