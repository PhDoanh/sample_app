class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]
    if user&.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = t(".flash_success")
      redirect_to user
    else
      flash[:danger] = t(".flash_danger")
      redirect_to root_path, status: :see_other
    end
  end
end
