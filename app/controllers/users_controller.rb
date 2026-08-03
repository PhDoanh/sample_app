class UsersController < ApplicationController
  before_action :logged_in_user, only:
    %i(index edit update destroy following followers)
  before_action :load_user, only:
    %i(show edit update destroy following followers)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @pagy, @users = pagy(
      :offset,
      User.newest,
      limit: Settings.users_per_page
    )
  end

  def new
    @user = User.new
  end

  def show
    @pagy, @microposts = pagy(
      :offset,
      @user.microposts.recent,
      limit: Settings.microposts_per_page
    )
    @users = @user.followers
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t(".flash_info")
      redirect_to root_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t(".flash_success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.admin? && !current_user?(@user)
      @user.destroy
      flash[:success] = t(".flash_success")
    else
      flash[:danger] = t(".flash_danger")
    end
    redirect_to users_path, status: :see_other
  end

  def following
    @title = t(".title")
    @pagy, @users = pagy(
      :offset,
      @user.following,
      limit: Settings.users_per_page
    )
    render "show_follow", status: :unprocessable_entity
  end

  def followers
    @title = t(".title")
    @pagy, @users = pagy(
      :offset,
      @user.followers,
      limit: Settings.users_per_page
    )
    render "show_follow", status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit(
      :name, :email, :password, :password_confirmation
    )
  end

  def load_user
    @user = User.find_by id: params[:id]
    redirect_to root_path, status: :see_other unless @user
  end

  def correct_user
    redirect_to root_path, status: :see_other unless current_user? @user
  end
end
