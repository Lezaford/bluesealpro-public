class TechniciansController < ApplicationController
  before_action :set_technician, only: [ :show, :edit, :update, :destroy ]

  def index
    @technicians = Current.company.technicians.by_name
  end

  def new
    @technician = Current.company.technicians.build
  end

  def create
    # Check tech account limit (5 per company)
    tech_count = Current.company.users.where(role: :tech).count
    if tech_count >= 5
      redirect_to technicians_url, alert: "You've reached the maximum of 5 technician accounts. Please upgrade to add more."
      return
    end

    @technician = Current.company.technicians.build(technician_params)

    # Create user account for technician if email is provided
    if @technician.valid? && technician_params[:email].present?
      begin
        temporary_password = SecureRandom.alphanumeric(12)
        user = Current.company.users.build(
          name: @technician.name,
          email: technician_params[:email],
          password: temporary_password,
          password_confirmation: temporary_password,
          role: :tech,
          password_change_required: true
        )

        if user.save
          @technician.user = user
          if @technician.save
            # Send welcome email with temporary password
            TechnicianMailer.welcome_email(user, temporary_password).deliver_later
            redirect_to technicians_url, notice: "Technician created successfully. Login email sent to #{user.email}."
          else
            user.destroy
            render :new, status: :unprocessable_entity
          end
        else
          @technician.errors.add(:email, user.errors.full_messages.join(", "))
          render :new, status: :unprocessable_entity
        end
      rescue => e
        @technician.errors.add(:base, "Error creating account: #{e.message}")
        render :new, status: :unprocessable_entity
      end
    elsif @technician.save
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
  end
end
