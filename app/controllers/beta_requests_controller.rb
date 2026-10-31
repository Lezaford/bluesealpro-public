class BetaRequestsController < ApplicationController
  # Replaces the removed captcha: throttle public form submissions per IP.
  rate_limit to: 5, within: 1.minute, only: :create,
             with: -> { redirect_to root_path(anchor: "beta"), alert: "Too many requests. Please try again shortly." }

  def create
    @beta_request = BetaRequest.new(beta_request_params)

    if @beta_request.save
      BetaRequestMailer.new_request(@beta_request).deliver_later
      redirect_to root_path, notice: "Thanks! We will contact you when a beta slot is available."
    else
      flash[:alert] ||= @beta_request.errors.full_messages.to_sentence.presence || "Please check the form and try again."
      redirect_to root_path(anchor: "beta")
    end
  rescue ActionController::ParameterMissing
    flash[:alert] = "Something went wrong with the form. Please try again."
    redirect_to root_path(anchor: "beta")
  end

  private

  def beta_request_params
    params.require(:beta_request).permit(:name, :email, :company, :phone, :message)
  end
end
