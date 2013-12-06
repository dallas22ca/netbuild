module Api
  class ApplicationController < ActionController::Base
    skip_before_filter :verify_authenticity_token
    before_filter :restrict_access
    
  private
  
    def restrict_access
      if request.authorization.to_s =~ /token\=/
        authenticate_or_request_with_http_token do |token|
          @membership = Membership.where(token: token).first
          @website = @membership.website
          true
        end
      elsif request.authorization.to_s
        begin
          authenticate_or_request_with_http_basic do |email, password|
            @user = User.where(email: email).first
            
            if @user
              @membership = @user.memberships.where(token: password).first
              
              if @membership
                @website = @membership.website
                true
              end
            end
          end
        rescue
          render text: "404 Unauthenticated"
        end
      end
    end
  end
end