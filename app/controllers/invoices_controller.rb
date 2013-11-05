class InvoicesController < ApplicationController
  before_action :authenticate_website_admin?
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
    if request.path.include? "billing"
      netbuild = Website.where(permalink: "nb-www").first
      @invoices = netbuild.invoices.where(netbuild_website_id: current_user.website_ids)
    else
      @invoices = @website.invoices
    end
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    respond_to do |format|
      format.html
      format.json
      format.pdf { render pdf: "NetBuild.co Invoice - #{@invoice.date.strftime("%m-%d-%Y") if @invoice.date}" }
    end
  end
  
  def new
    @invoice = Invoice.new(
      lines: [{ "description" => "", "amount" => "", "quantity" => "1", "unit_price" => "" }],
      date: Time.zone.now
    )
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Invoice was successfully created.' }
        format.json { render action: 'show', status: :created, location: @invoice }
      else
        format.html { render action: 'new' }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Invoice was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    respond_to do |format|
      if @invoice.websites.empty?
        @invoice.destroy
        format.html { redirect_to invoices_url }
        format.json { head :no_content }
      else
        format.html { render "show", notice: "You cannot delete this invoice because your website is using it." }
        format.json { head :no_content }
      end
    end
  end

  private

    def set_invoice
      @invoice = @website.invoices.where(visible_id: params[:id]).first
    end
    
    def invoice_params
      params[:invoice][:lines].each do |line|
        line[:amount] = line[:amount].to_f * 100
        line[:unit_price] = line[:unit_price].to_f * 100
      end
      
      if current_user.try(:admin?)
        params.require(:invoice).permit(:total_in_dollars, :subtotal_in_dollars, :paid, :membership_id, :date, :tax_rate, :public_access, lines: [:amount, :description, :quantity, :unit_price])
      else
        params.require(:invoice).permit(:total_in_dollars, :subtotal_in_dollars, :paid, :membership_id, :date, :tax_rate, :public_access, lines: [:amount, :description, :quantity, :unit_price])
      end
    end
end
