class TechniciansController < ApplicationController
  before_action :set_technician, only: [ :show, :edit, :update, :destroy ]

  def index
    @technicians = Current.company.technicians.by_name
  end

  def new
    @technician = Current.company.technicians.build
  end

  def create
    @technician = Current.company.technicians.build(technician_params)

    if @technician.save
      redirect_to technicians_url, notice: "Technician was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @technician.update(technician_params)
      redirect_to technicians_url, notice: "Technician was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @technician.destroy
    redirect_to technicians_url, notice: "Technician was successfully deleted."
  rescue ActiveRecord::InvalidForeignKeyValue
    redirect_to technicians_url, alert: "Cannot delete technician with assigned jobs."
  end

  private

  def set_technician
    @technician = Current.company.technicians.find(params[:id])
  end

  def technician_params
    params.require(:technician).permit(:name, :phone, :email, :notes, :active)
  end
end
