class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Method

  around_action :switch_locale

  private

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("users.logged_in_user.flash_danger")
    redirect_to login_path, status: :see_other
  end

  def admin_user
    redirect_to root_path, status: :see_other unless current_user.admin?
  end
end
