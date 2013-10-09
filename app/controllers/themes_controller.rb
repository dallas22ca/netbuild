class ThemesController < ApplicationController
  before_action :set_theme, only: [:edit, :update, :destroy]

  # GET /themes
  # GET /themes.json
  def index
    if @website
      @themes = @website.available_themes
    else
      @themes = Theme.pristine
    end
  end

  # GET /themes/1
  # GET /themes/1.json
  def show
    if @website
      @theme = @website.available_themes.find(params[:id])
    else
      @theme = Theme.pristine.find(params[:id])
    end
  end

  # GET /themes/new
  def new
    @theme = Theme.new
  end

  # GET /themes/1/edit
  def edit
  end

  # POST /themes
  # POST /themes.json
  def create
    @theme = Theme.new(theme_params)
    @theme.website_id = @website.id

    respond_to do |format|
      if @theme.save
        format.html { redirect_to @theme, notice: 'Theme was successfully created.' }
        format.json { render action: 'show', status: :created, location: @theme }
      else
        format.html { render action: 'new' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /themes/1
  # PATCH/PUT /themes/1.json
  def update
    respond_to do |format|
      if @theme.update(theme_params)
        format.html { redirect_to @theme, notice: 'Theme was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @theme.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.json
  def destroy
    respond_to do |format|
      if @theme.websites.empty?
        @theme.destroy
        format.html { redirect_to themes_url }
        format.json { head :no_content }
      else
        format.html { render "show", notice: "You cannot delete this theme because your website is using it." }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_theme
      @theme = @website.editable_themes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def theme_params
      if current_user.try(:admin?)
        params.require(:theme).permit(:name, :default_document_id, :pristine)
      else
        params.require(:theme).permit(:name, :default_document_id)
      end
    end
end
