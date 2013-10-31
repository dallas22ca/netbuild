class ApplicationController < ActionController::Base
  before_filter :secure_www, if: Proc.new { request.subdomain == "www" && Rails.env.production? }
  protect_from_forgery with: :exception
  before_filter :set_website

  private
  
  def secure_www
    redirect_to :protocol => 'https://', :status => :moved_permanently
  end
  
  def set_website
    if request.domain == CONFIG["domain"]
      if %w[www help faq].include? request.subdomain
        @website = Website.where(permalink: "nb-#{request.subdomain}").first
      else
        @website = Website.where(permalink: request.subdomain).first
      end
    else
      @website = Website.where(domain: "#{request.subdomain + "." unless request.subdomain.blank?}#{request.domain}").first
      @website = Website.where(domain: request.domain).first if !@website
    end
  end
  
  def signed_in?
    if user_signed_in?
      @signed_in ||= @website && @website.memberships.where(user_id: current_user.id).any?
    else
      @signed_in ||= false
    end
  end
  helper_method :signed_in?
  
  def current_membership
    current_user.memberships.where(website_id: @website.id).first
  end
  helper_method :current_membership
  
  def authenticate_adminable?
    if !user_signed_in? || !@website.adminable_by(current_user)
      redirect_to root_path
    end
  end
  helper_method :authenticate_adminable?
  
  def authenticate_super_admin?
    unless user_signed_in? && current_user.admin?
      redirect_to root_path
    end
  end
  helper_method :authenticate_super_admin?
  
  def super_admin?
    user_signed_in? && current_user.admin?
  end
  helper_method :super_admin?
  
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
