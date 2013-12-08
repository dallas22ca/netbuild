class ResponsesController < ApplicationController
  before_action :authenticate_website_admin?, except: [:create]

  # GET /responses
  # GET /responses.json
  def index
    @responses = @website.responses.includes(:page)
  end

  # GET /responses/1
  # GET /responses/1.json
  def show
    @response = @website.responses.find(params[:id])
  end
  
  # POST /responses
  # POST /responses.json
  def create
    @block = @website.blocks.find(params[:block_id])
    @membership = @website.memberships.find(params[:membership_id])
    @response = @website.responses.new(block_id: @block.id, membership_id: @membership.id, data: params[:data])

    respond_to do |format|
      if @response.save
        format.html { redirect_to :back, notice: 'Response was successfully created.' }
        format.json { render action: 'show', status: :created, location: @response }
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @response.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  private
  
    def response_params
      params.require(:response).permit(:block_id, :data, :contact_id, :website_id)
    end
end
