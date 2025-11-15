class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  # GET /customers
  def index
    scope = Current.company.customers.order(last_name: :asc, first_name: :asc)
    if params[:q].present?
      q = "%#{params[:q].strip}%"
      scope = scope.where(
        "LOWER(first_name) LIKE LOWER(?) OR LOWER(last_name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR phone LIKE ?",
        q, q, q, q
      )
    end
    @customers = scope
    # If you're using pagination (e.g., kaminari), uncomment:
    # @customers = scope.page(params[:page]).per(25)
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

  def customer_params
    params.require(:customer).permit(
      :first_name, :last_name, :email, :phone,
      :address1, :address2, :city, :state, :zip,
      :notes
    )
  end
end
