class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = @website.invoices
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  private

    def set_invoice
      @invoice = @website.invoices.find(params[:id])
    end
end
