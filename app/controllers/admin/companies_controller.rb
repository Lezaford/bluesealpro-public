class Admin::CompaniesController < Admin::BaseController
  def edit
    @company = current_company
  end

  def update
    @company = current_company
    if @company.update(company_params)
      redirect_to edit_admin_company_path, notice: "Company settings updated successfully."
    else
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :phone,
      :email,
      :ein,
      :website_url,
      :address_line1,
      :address_line2,
      :city,
      :state,
      :zip,
      :time_zone,
      :logo
    )
  end
end
