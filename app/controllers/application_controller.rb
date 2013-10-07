class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :set_website, unless: Proc.new { request.subdomain == "www" }

  private
  
  def set_website
    @website = Website.where(permalink: request.subdomain).first
    p ">>>>>>>>>>> #{request.subdomain}"
    p "<<<<<<<<<<< #{@website.permalink}"
  end
  
  def signed_in?
    if user_signed_in?
      @signed_in ||= @website && @website.memberships.where(user_id: current_user.id).any?
    else
      @signed_in ||= false
    end
  end
  helper_method :signed_in?
  
  def adminable?
    if user_signed_in?
      @adminable ||= @website && @website.memberships.admin.where(user_id: current_user.id).any?
    else
      @adminable ||= false
    end
  end
  helper_method :adminable?
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :subdomain) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password, :time_zone, :address) }
  end
  
end
