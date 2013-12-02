class RegistrationsController < Devise::RegistrationsController
  def create    
    begin
      build_resource(sign_up_params)
      
      if @website.allow_signups?
        resource.website_id = @website.id
        resource.security = "user"
        
        if resource.save
          sign_in(resource_name, resource)
          respond_with resource, location: root_path
        end
      end
    rescue
      flash[:notice] = resource.errors.full_messages
      clean_up_passwords resource
      redirect_to :back
    end
  end
end