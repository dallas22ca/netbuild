class RegistrationsController < Devise::RegistrationsController
  def create
    if request.subdomain == "www"
      super
    else
      build_resource(sign_up_params)
    
      if resource.save
        @website.memberships.create user_id: resource.id
        sign_in(resource_name, resource)
        respond_with resource, location: root_path
      else
        clean_up_passwords resource
        redirect_to :back
      end
    end
  end
end