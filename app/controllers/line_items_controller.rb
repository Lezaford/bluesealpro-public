class LineItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice
  before_action :set_line_item, only: [ :update, :destroy ]
  before_action :authorize_line_item_access!

  def create
    @line_item = @invoice.line_items.build(line_item_params)
    @line_item.company_id = Current.company.id

    # If adding from price book (admin only)
    if line_item_params[:price_book_item_id].present?
      authorize_admin!
      pbi = Current.company.price_book_items.find(line_item_params[:price_book_item_id])
      @line_item.description = pbi.name
      @line_item.category = pbi.category
      @line_item.unit_price_cents = pbi.unit_price_cents
      @line_item.taxable = pbi.taxable
      @line_item.locked = (pbi.lock_policy == "admin_only")
      @line_item.price_book_item_id = pbi.id
    else
      # Tech adding custom material
      @line_item.locked = false
    end

    if @line_item.save
      redirect_to edit_invoice_path(@invoice), notice: "Line item added."
    else
      redirect_to edit_invoice_path(@invoice), alert: "Failed to add line item: #{@line_item.errors.full_messages.to_sentence}"
    end
  end

  def update
    # Prevent updates to locked items unless admin/owner
    if @line_item.locked? && !current_user.role_owner? && !current_user.role_admin?
      render json: { error: "Cannot edit locked line item" }, status: :forbidden
      return
    end

    if @line_item.update(line_item_params)
      redirect_to edit_invoice_path(@invoice), notice: "Line item updated."
    else
      redirect_to edit_invoice_path(@invoice), alert: "Failed to update line item: #{@line_item.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    # Prevent delete of locked items unless admin/owner
    if @line_item.locked? && !current_user.role_owner? && !current_user.role_admin?
      render json: { error: "Cannot delete locked line item" }, status: :forbidden
      return
    end

    @line_item.destroy
    redirect_to edit_invoice_path(@invoice), notice: "Line item removed."
  end

  private

  def set_invoice
    @invoice = Current.company.invoices.find(params[:invoice_id])
  end

  def set_line_item
    @line_item = @invoice.line_items.find(params[:id])
  end

  def authorize_line_item_access!
    # Tech can only add/edit materials
    if current_user.role_tech?
      if action_name == "create" && line_item_params[:category].present?
        return if line_item_params[:category] == "materials"
        redirect_to edit_invoice_path(@invoice), alert: "Technicians can only add materials."
      end
    end
  end

  def authorize_admin!
    redirect_to edit_invoice_path(@invoice), alert: "Access denied." unless current_user.role_owner? || current_user.role_admin?
  end

  def line_item_params
    allowed_params = [ :category, :description, :quantity, :unit_price_cents, :taxable ]
    allowed_params << :price_book_item_id if current_user.role_owner? || current_user.role_admin?
    params.require(:line_item).permit(*allowed_params)
  end
end
