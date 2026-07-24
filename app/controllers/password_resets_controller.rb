class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)

  def new; end

  def edit; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t(".flash_info")
      redirect_to root_path, status: :see_other
    else
      flash.now[:danger] = t(".flash_danger")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t(".flash_danger"))
      render :edit, status: :unprocessable_entity
    elsif @user.update user_params
      reset_session
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t(".flash_success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by email: params[:email]
    redirect_to root_path, status: :see_other unless @user
  end

  def valid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    redirect_to root_path, status: :see_other
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t("password_resets.check_expiration.flash_danger")
    redirect_to new_password_reset_path, status: :see_other
  end
end
