class WebsitesController < ApplicationController
  # GET /websites
  # GET /websites.json
  def index
    @websites = Website.all
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
  end

  # POST /websites
  # POST /websites.json
  def create
    @website = Website.new(website_params)

    respond_to do |format|
      if @website.save
        sign_in @website.members.first
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
    respond_to do |format|
      if @website.update(website_params)
        format.html { redirect_to @website, notice: 'Website was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @website.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def save
    @deleted = []
    @new = []
    
    @page = @website.pages.find(params[:page_id])
    
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
              details: block[:details]
            )
          end
        elsif block[:delete] != "true"
          b = @website.blocks.create(
            wrapper_id: block[:wrapper_id],
            genre: block[:genre],
            ordinal: block[:ordinal],
            details: block[:details],
            initial_id: block[:id]
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
    
    if params[:title]
      @page.update_attributes(title: params[:title])
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

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def website_params
      params.require(:website).permit(:title, :domain, :permalink, :theme_id, :duplicate_theme, :home_id, members_attributes: [:email, :password])
    end
end
