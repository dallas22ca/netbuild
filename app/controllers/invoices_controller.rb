class InvoicesController < ApplicationController
  before_action :authenticate_adminable?
  before_action :set_invoice, only: [:show]

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
  end

  private

    def set_invoice
      @invoice = @website.invoices.where(visible_id: params[:id]).first
    end
end
