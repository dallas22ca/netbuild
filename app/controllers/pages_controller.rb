class PagesController < ApplicationController
  before_action :authenticate_website_admin?, except: [:show]
  layout :choose_layout
  before_action :set_page, only: [:edit, :update, :destroy]

  # GET /pages
  # GET /pages.json
  def index
    @pages = @website.pages
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @path = request.path
    
    if params[:post]
      start = Time.parse("#{params[:year]}/#{params[:month]}")
      finish = start.end_of_month
      
      if params[:permalink]
        @parent = @website.pages.dated.where(permalink: params[:permalink]).first
      elsif @website.home.has_children?
        @parent = @website.home
      end
      
      @page = @parent.children.where("permalink = ? and published_at >= ? and published_at <= ?", params[:post], start, finish).first if @parent
    elsif params[:month]
      @page = @website.pages.dated.where(permalink: params[:permalink]).first
      @month = params[:month]
      @year = params[:year]
    elsif params[:year]
      @page = @website.pages.dated.where(permalink: params[:permalink]).first
      @year = params[:year]
    elsif params[:c]
      @grandparent = @website.pages.roots.not_dated.where(permalink: params[:a]).first
      @parent = @grandparent.children.not_dated.where(permalink: params[:b]).first
      @page = @parent.children.not_dated.where(permalink: params[:c]).first
    elsif params[:b]
      @parent = @website.pages.roots.not_dated.where(permalink: params[:a]).first
      @page = @parent.children.not_dated.where(permalink: params[:b]).first
    elsif params[:a]
      @page = @website.pages.roots_or_dated.where(permalink: params[:a]).first
    elsif @website.home.has_children? && !@website.children_have_dates?
      @page = @website.home.children.where(permalink: params[:a]).first
    elsif @website
      @page = @website.home
    end
    
    if @page
      @blocks = {}
      @page.layout.body.scan(/wrapper_(.*?)(\s|\})/).each do |b|
        wrapper = { identifier: b.first }
        wrapper[:page_id] = @page.id if wrapper[:identifier] =~ /\?/
			  @blocks["wrapper_#{wrapper[:identifier]}"] = render_to_string(@website.wrappers.where(wrapper).first_or_create)
      end
      
      @current_user_details = {}
      if user_signed_in?
      	@current_user_details["current_user_email"] = current_user.email
      end
    end
    
    if params[:a] == "invoices" && params[:id]
      @invoice = @website.invoices.where(visible_id: params[:id]).first
      
      unless @invoice.public_access?
        if @invoice.membership_id != current_membership.id
          @invoice = nil
        end
      end
    end
    
    respond_to do |format|
      format.html do
        if @path != root_path && @page == @website.home
          redirect_to root_path
        elsif !@page.redirect_to.blank?
          redirect_to @page.redirect_to
        elsif !@website
          render text: "This website does not exist."
        end
      end
      format.pdf { render pdf: "#{@website.title} #{@invoice.date.strftime("%m-%d-%Y")}" } if @invoice
      format.json
    end
  end

  # GET /pages/new
  def new
    @page = Page.new(published: true, document_id: @website.theme.default_document_id)
  end

  # GET /pages/1/edit
  def edit
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = @website.pages.new(page_params)

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page.path, notice: 'Page was successfully created.' }
        format.json { render action: 'show', status: :created, location: @page }
      else
        format.html { render action: 'new' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pages/1
  # PATCH/PUT /pages/1.json
  def update
    respond_to do |format|
      if @page.update(page_params)
        format.html { redirect_to (@page.redirect_to.blank? ? @page.path : manage_path("pages")), notice: 'Page was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @page.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page.destroy
    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = @website.pages.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:title, :description, :visible, :ordinal, :document_id, :parent_id, :permalink, :published, :published_at, :redirect_to, :children_have_dates)
    end
    
    def choose_layout
      if action_name == "show"
        if website_admin?
          "editor"
        else
          "public"
        end
      end
    end
end
