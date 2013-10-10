class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def webhook
    begin
      json = JSON.parse(request.body.read)
      
      if json["type"].include? "invoice"
        # website = Website.where(customer_token: json["data"]["customer"]).first.try(:id)
        website = Website.first
        invoice = website.invoices.where(stripe_id: json["id"]).first_or_initialize
        
        if json["type"].include? "create"
          Invoice.add_addons_to_invoices invoice.website.id
          render json: { invoice_created: "Now adding addons to the invoice." }
        else
          invoice.date = Time.at(json["date"])
          invoice.period_start = Time.at(json["period_start"])
          invoice.period_end = Time.at(json["period_end"])
          invoice.lines = json["lines"]["data"]
          invoice.subtotal = json["subtotal"]
          invoice.total = json["total"]
          invoice.paid = json["paid"]
          invoice.attempt_count = json["attempt_count"]
          render json: invoice
        end
      end
    rescue
      render json: { fail: true }
    end
  end
  
  def json
    {
      "date" => 1381334108,
      "id" => "in_102ir024WTG8yf9AwyJqgXY6",
      "period_start" => 1381334108,
      "period_end" => 1381334108,
      "lines" => {
        "data" => [
          {
            "id" => "su_102itC24WTG8yf9Akw68tGcZ",
            "object" => "line_item",
            "type" => "subscription",
            "livemode" => true,
            "amount" => 4000,
            "currency" => "cad",
            "proration" => false,
            "period" => {
              "start" => 1384012508,
              "end" => 1386604508
            },
            "quantity" => 1,
            "plan" => {
              "interval" => "month",
              "name" => "Web \u0026 Email Hosting",
              "amount" => 4000,
              "currency" => "cad",
              "id" => "WEH",
              "object" => "plan",
              "livemode" => false,
              "interval_count" => 1,
              "trial_period_days" => nil
            },
            "description" => nil
          }
        ],
        "count" => 1,
        "object" => "list",
        "url" => "/v1/invoices/in_102ir024WTG8yf9AwyJqgXY6/lines"
      },
      "subtotal" => 4000,
      "total" => 4000,
      "customer" => "cus_2ir0Ihgs11IZ7r",
      "object" => "invoice",
      "attempted" => true,
      "closed" => true,
      "paid" => true,
      "livemode" => false,
      "attempt_count" => 0,
      "amount_due" => 4000,
      "currency" => "cad",
      "starting_balance" => 0,
      "ending_balance" => 0,
      "next_payment_attempt" => nil,
      "charge" => "ch_102ir024WTG8yf9AVb71BLSg",
      "discount" => nil,
      "application_fee" => nil
    }
  end
end
