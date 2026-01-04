class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  # GET /customers
  def index
    @query         = params[:q].to_s.strip
    @customer_type = params[:customer_type].to_s.strip
    @lead_source   = params[:lead_source].to_s.strip

    # options for dropdowns - safely handle empty results
    base = Current.company.customers
    @customer_types = base.where.not(customer_type: nil).distinct.pluck(:customer_type).compact_blank.sort
    @lead_sources   = base.where.not(lead_source: nil).distinct.pluck(:lead_source).compact_blank.sort

    scope = base_scope
    @customers = scope.order(last_name: :asc, first_name: :asc)
  end


  # POST /customers/import
  def import
    if params[:import_file].blank?
      redirect_to customers_path, alert: "Please choose a CSV file to import."
      return
    end

    begin
      count = Customer.import(params[:import_file], company: Current.company)
      redirect_to customers_path, notice: "Successfully imported #{count} customer(s)."
    rescue => e
      redirect_to customers_path, alert: "Import failed: #{e.message}"
    end
  end

  # GET /customers/export
  def export
    scope = base_scope

    csv = Customer.to_csv(scope)
    send_data csv,
              filename: "customers-#{Time.current.to_date}.csv",
              type: "text/csv"
  end

  # GET /customers/:id
  def show
  end

  # GET /customers/new
  def new
    @customer = Current.company.customers.new
  end

  # GET /customers/:id/edit
  def edit
  end

  # POST /customers
  def create
    @customer = Current.company.customers.new(customer_params)
    if @customer.save
      redirect_to @customer, notice: "Customer was created."
    else
      flash.now[:alert] = @customer.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /customers/:id
  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: "Customer was updated."
    else
      flash.now[:alert] = @customer.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /customers/:id
  def destroy
    @customer.destroy
    redirect_to customers_path, notice: "Customer was deleted."
  end

  private

  def set_customer
    # Multi-tenant secure lookup — only within the signed-in user’s company
    @customer = Current.company.customers.find(params[:id])
  end

  # Shared base scope for index + export (search + filters)
  def base_scope
    scope = Current.company.customers

    if params[:q].present?
      q = "%#{params[:q].strip.downcase}%"
      scope = scope.where(
        "LOWER(first_name) LIKE :q OR LOWER(last_name) LIKE :q OR " \
        "LOWER(email) LIKE :q OR LOWER(phone) LIKE :q OR " \
        "LOWER(display_name) LIKE :q OR LOWER(company_name) LIKE :q",
        q: q
      )
    end

    if params[:customer_type].present?
      scope = scope.where(customer_type: params[:customer_type])
    end

    if params[:lead_source].present?
      scope = scope.where(lead_source: params[:lead_source])
    end

    scope
  end

  def customer_params
    params.require(:customer).permit(
      # existing fields
      :first_name,
      :last_name,
      :email,
      :phone,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :notes,

      # new CSV-related fields
      :display_name,
      :mobile_number,
      :home_number,
      :additional_emails,
      :company_name,
      :role,
      :work_number,
      :bills_to,
      :accepts_bills_from,
      :tags,
      :external_id,
      :customer_type,
      :customer_notifications_enabled,
      :customer_is_contractor,
      :lead_source,
      :customer_created_at,
      :last_service_date,
      :lifetime_value,
      :address_1_street_line_1,
      :address_1_street_line_2,
      :address_1_city,
      :address_1_state,
      :address_1_postal_code,
      :address_1_billing,
      :address_1_notes,
      :address_2_street_line_1,
      :address_2_street_line_2,
      :address_2_city,
      :address_2_state,
      :address_2_postal_code,
      :address_2_billing,
      :address_2_notes,
      :address_3_street_line_1,
      :address_3_street_line_2,
      :address_3_city,
      :address_3_state,
      :address_3_postal_code,
      :address_3_billing,
      :address_3_notes,
      :address_4_street_line_1,
      :address_4_street_line_2,
      :address_4_city,
      :address_4_state,
      :address_4_postal_code,
      :address_4_billing,
      :address_4_notes
    )
  end
end
