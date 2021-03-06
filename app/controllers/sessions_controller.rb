class SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate(auth_options)
    
    if resource && resource.websites.where(permalink: request.subdomain).any?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      flash[:notice] = "Your username or password is incorrect."
      redirect_to :back
    end
  end
end