class RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)
  
    if resource.save
      if resource.memberships.create! website_id: @website.id, security: "user"
        sign_in(resource_name, resource)
        respond_with resource, location: root_path
      else
        flash[:notice] = resource.errors.full_messages
        clean_up_passwords resource
        redirect_to :back
      end
    else
      flash[:notice] = resource.errors.full_messages
      clean_up_passwords resource
      redirect_to :back
    end
  end
end