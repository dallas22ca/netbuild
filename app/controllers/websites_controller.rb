class WebsitesController < ApplicationController
  before_action :authenticate_website_admin?
  
  # GET /websites
  # GET /websites.json
  def index
    @websites = current_user.websites
  end

  # GET /websites/1
  # GET /websites/1.json
  def show
  end

  # GET /websites/new
  def new
    @website = Website.new
    @website.members.build
  end

  # GET /websites/1/edit
  def edit
    params[:feature] ||= "theme"
    render "websites/edit/#{params[:feature]}"
  end

  # POST /websites
  # POST /websites.json
  def create
    @website = Website.new(create_website_params)
    @website.members.push current_user if user_signed_in?

    respond_to do |format|
      if @website.save
        sign_in @website.members.first unless user_signed_in?
        format.html { redirect_to root_url(subdomain: @website.permalink), notice: 'Website was successfully created.' }
        format.json { render action: 'show', status: :created, location: @website }
      else
        format.html { render action: 'new' }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /websites/1
  # PATCH/PUT /websites/1.json
  def update
    @deleted = []
    @new = []
    
    @page = @website.pages.where(id: params[:page_id]).first
    
    if params[:blocks]
      params[:blocks].each do |key, block|
        b = @website.blocks.where(id: block[:id]).first
      
        if b
          if block[:delete] == "true"
            @deleted.push b.id
            b.destroy
          else
            b.update_attributes(
              wrapper_id: block[:wrapper_id],
              genre: block[:genre],
              ordinal: block[:ordinal],
              data: block[:data]
            )
          end
        elsif block[:delete] != "true"
          b = Block.create(
            wrapper_id: block[:wrapper_id],
            genre: block[:genre],
            ordinal: block[:ordinal],
            data: block[:data],
            initial_id: block[:initial_id],
            website_id: @website.id
          )
          @new.push b
        end
      end
    end
    
    if params[:pages]
      params[:pages].each_with_index do |id, index|
        id = id.gsub("page_", "")
        p = @website.pages.where(id: id).first
        p.update_attributes ordinal: index if p
      end
    end
    
    if @page && params[:title]
      @page.update_attributes(title: params[:title])
    end
    
    respond_to do |format|
      if @website.update(website_params)
        format.html { redirect_to params[:redirect], notice: 'Website was successfully updated.' }
        format.json { head :no_content }
        format.js
      else
        format.html { render "websites/edit/#{params[:redirect].split("/").last}" }
        format.json { render json: @website.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /websites/1
  # DELETE /websites/1.json
  def destroy
    @website.destroy
    respond_to do |format|
      format.html { redirect_to websites_url }
      format.json { head :no_content }
    end
  end
  
  def feed
    respond_to do |format|
      format.atom { render layout: false }
      format.rss { redirect_to feed_path(format: :atom), status: :moved_permanently }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def create_website_params
      params.require(:website).permit(:title, :permalink, :theme_id, members_attributes: [:email, :password])
    end
    
    def website_params
      if super_admin?
        params.require(:website).permit(:title, :domain, :theme_id, :duplicate_theme, :home_id, :primary_colour, :secondary_colour, :header, :warnings, :card_token, :customer_token, :stripe_access_token, :stripe_user_id, :address, :invoice_blurb, addon_ids: [])
      elsif @website.adminable_by(current_user)
        params.require(:website).permit(:title, :domain, :theme_id, :duplicate_theme, :home_id, :primary_colour, :secondary_colour, :header, :warnings, :card_token, :stripe_access_token, :stripe_user_id, :address, :invoice_blurb, addon_ids: [])
      else
        params.require(:website).permit(:title, :domain, :theme_id, :duplicate_theme, :home_id, :primary_colour, :secondary_colour, :header, :warnings)
      end
    end
end
