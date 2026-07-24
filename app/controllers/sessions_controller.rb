class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by({email: params[:session][:email].downcase})
    if user&.authenticate(params[:session][:password])
      login_if_activated user
    else
      flash.now[:danger] = t(".flash_danger")
      render "new", status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path, status: :see_other
  end

  private
  def remember_or_forget user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end

  def login_if_activated user
    if user.activated?
      reset_session
      remember_or_forget user
      log_in user
      redirect_back_or user
    else
      flash.now[:warning] = t("sessions.create.flash_warning")
      render "new", status: :unprocessable_entity
    end
  end
end
