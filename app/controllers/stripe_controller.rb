class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def webhook
    begin
      object = json["data"]["object"]

      if json["type"].include? "invoice"
        website = Website.where(customer_token: object["customer"]).first
        invoice = website.invoices.where(stripe_id: object["id"]).first_or_initialize
        invoice.date = Time.at(object["date"])
        invoice.period_start = Time.at(object["period_start"])
        invoice.period_end = Time.at(object["period_end"])
        invoice.lines = object["lines"]["data"]
        invoice.subtotal = object["subtotal"]
        invoice.total = object["total"]
        invoice.paid = object["paid"]
        invoice.attempt_count = object["attempt_count"]
        invoice.save
        Invoice.add_addons_to_invoices website if json["type"].include? "create"
        render json: invoice
      end
    rescue
      render json: { fail: true }
    end
  end
  
  def json
    {
      "created" => 1326853478,
      "livemode" => false,
      "id" => "evt_00000000000000",
      "type" => "invoice.updated",
      "object" => "event",
      "data" => {
        "object" => {
          "date" => 1381408468,
          "id" => "in_00000000000000",
          "period_start" => 1381408468,
          "period_end" => 1381408468,
          "lines" => {
            "data" => [
              {
                "id" => "su_102jWR24WTG8yf9A5BVqeCid",
                "object" => "line_item",
                "type" => "subscription",
                "livemode" => true,
                "amount" => 4000,
                "currency" => "cad",
                "proration" => false,
                "period" => {
                  "start" => 1384086868,
                  "end" => 1386678868
                },
                "quantity" => 1,
                "plan" => {
                  "interval" => "month",
                  "name" => "Web & Email Hosting",
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
            "url" => "/v1/invoices/in_102jB024WTG8yf9ALFGx2ijI/lines"
          },
          "subtotal" => 7000,
          "total" => 7000,
          "customer" => "hi",
          "object" => "invoice",
          "attempted" => true,
          "closed" => true,
          "paid" => true,
          "livemode" => false,
          "attempt_count" => 0,
          "amount_due" => 7000,
          "currency" => "cad",
          "starting_balance" => 0,
          "ending_balance" => 0,
          "next_payment_attempt" => nil,
          "charge" => "ch_00000000000000",
          "discount" => nil,
          "application_fee" => nil
        },
        "previous_attributes" => {
          "lines" => []
        }
      }
    }
  end
end
