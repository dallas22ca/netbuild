class MediaController < ApplicationController
  before_action :authenticate_website_admin?
  before_action :set_medium, only: [:show, :edit, :update, :destroy]

  # GET /media
  # GET /media.json
  def index
    if params[:media_q]
      @media = @website.media.where("name ilike :q or extension ilike :q or description ilike :q or filename ilike :q", q: "%#{params[:media_q]}%")
    elsif params[:tags]
      @media = @website.media.tagged_with(params[:tags])
    else
      @media = @website.media
    end
  end
  
  # GET /media/tags
  # GET /media/tags.json
  def tags
    @tags = Medium.where(website_id: @website.id).tag_counts_on(:tags)
  end

  # GET /media/1
  # GET /media/1.json
  def show
  end

  # GET /media/new
  def new
    @medium = Medium.new
  end

  # GET /media/1/edit
  def edit
  end

  # POST /media
  # POST /media.json
  def create
    @medium = @website.media.new(medium_params)

    respond_to do |format|
      if @medium.save
        format.html { redirect_to @medium, notice: 'Medium was successfully created.' }
        format.json { render action: 'show', status: :created, location: @medium }
        format.js
      else
        format.html { render action: 'new' }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /media/1
  # PATCH/PUT /media/1.json
  def update
    respond_to do |format|
      if @medium.update(medium_params)
        format.html { redirect_to @medium, notice: 'Medium was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render action: 'edit' }
        format.json { render json: @medium.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.json
  def destroy
    @medium.destroy
    respond_to do |format|
      format.html { redirect_to media_url }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medium
      @medium = @website.media.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medium_params
      params.require(:medium).permit(:path, :name, :description, :tag_list, :import)
    end
end
