class ResponsesController < ApplicationController
  before_action :authenticate_website_admin?, except: [:create]
  before_action :set_response, only: [:show]

  # GET /responses
  # GET /responses.json
  def index
    @responses = Response.all
  end

  # GET /responses/1
  # GET /responses/1.json
  def show
    @response = Response.find(params[:id])
  end

  # POST /responses
  # POST /responses.json
  def create
    @response = Response.new(response_params)

    respond_to do |format|
      if @response.save
        format.html { redirect_to @response, notice: 'Response was successfully created.' }
        format.json { render action: 'show', status: :created, location: @response }
      else
        format.html { render action: 'new' }
        format.json { render json: @response.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  
    def response_params
      params.require(:response).permit(:block_id, :data, :contact_id, :website_id)
    end
end
