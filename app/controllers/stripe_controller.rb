class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def callback
    client = OAuth2::Client.new(CONFIG["stripe_client_id"], CONFIG["stripe_api_key"], { site: 'https://connect.stripe.com', :authorize_url => '/oauth/callback' })
    
    if params[:code]
      @resp = client.auth_code.get_token(params[:code], params: { scope: "read_write" })
      @website.stripe_access_token = @resp.token
      @website.stripe_user_id = @resp["stripe_user_id"]
      @website.save
    end
    
    redirect_to manage_path("addons")
  end
  
  def webhook
    begin
      json = JSON.parse request.body.read
      object = json["data"]["object"]

      if json["type"].include? "invoice"
        website = Website.where(stripe_user_id: json["user_id"]).first
        
        if website
          membership = website.memberships.where(customer_token: object["customer"]).first
          
          unless membership
            customer = Stripe::Customer.retrieve(object["customer"])
            member = User.where(email: customer.email).first_or_initialize
            
            if member.new_record?
              member.no_password = true
              member.save
            end
            
            membership = website.memberships.where(user_id: member.id).first_or_initialize
            
            if membership.new_record?
              membership.security = "customer"
              membership.save
            end
          end
          
          invoice = membership.invoices.where(stripe_id: object["id"]).first_or_initialize
          
          if website.permalink == "nb-www"
            netbuild_website = Website.where(permalink: customer.description).first
            invoice.netbuild_website_id = netbuild_website.id if netbuild_website
          end
          
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
      "type" => "invoice.created",
      "object" => "event",
      "user_id" => "acct_00000000000000",
      "data" => {
        "object" => {
          "date" => 1381754481,
          "id" => "in_10000000000000",
          "period_start" => 1381754481,
          "period_end" => 1381754481,
          "lines" => {
            "data" => [
              {
                "id" => "su_102r2r24WTG8yf9AVjXHMHWa",
                "object" => "line_item",
                "type" => "subscription",
                "livemode" => true,
                "amount" => 4000,
                "currency" => "cad",
                "proration" => false,
                "period" => {
                  "start" => 1384432881,
                  "end" => 1387024881
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
                "description" => nil,
                "metadata" => nil
              }
            ],
            "count" => 1,
            "object" => "list",
            "url" => "/v1/invoices/in_102kg124WTG8yf9AId1fGqUP/lines"
          },
          "subtotal" => 6000,
          "total" => 6000,
          "customer" => "cus_2jiMJg39dcvgzz",
          "object" => "invoice",
          "attempted" => false,
          "closed" => true,
          "paid" => false,
          "livemode" => false,
          "attempt_count" => 0,
          "amount_due" => 4000,
          "currency" => "cad",
          "starting_balance" => 0,
          "ending_balance" => 0,
          "next_payment_attempt" => nil,
          "charge" => "ch_00000000000000",
          "discount" => nil,
          "application_fee" => nil
        }
      }
    }
  end
end
