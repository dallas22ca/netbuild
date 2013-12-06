module Api
  module V1
    class MembersController < ApplicationController
      respond_to :json

      def index
        respond_with @website.members.page(params[:page]).per_page(50)
      end

      def show
        respond_with @website.members.find(params[:id])
      end

      def create
        overwrite = params[:overwrite]
        overwrite ||= false
        render json: @website.import_members(params[:members], { overwrite: overwrite })
      end

      def update
        respond_with @website.members.update(params[:id], params[:member])
      end

      def destroy
        respond_with @website.members.destroy(params[:id])
      end
    end
  end
end