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
      # json = JSON.parse request.body.read
      object = json["data"]["object"]

      if json["type"].include? "invoice"
        website = Website.where(stripe_user_id: json["user_id"]).first
        p "----------- #{json["user_id"]} -----------"
        
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
    {"id"=>"evt_102r9V24WTG8yf9A8lnhd1Go", "created"=>1383248012, "livemode"=>true, "type"=>"invoice.updated", "data"=>{"object"=>{"date"=>1383240537, "id"=>"in_102r7U24WTG8yf9AKiZgk2K4", "period_start"=>1383240537, "period_end"=>1383240537, "lines"=>{"object"=>"list", "count"=>1, "url"=>"/v1/invoices/in_102r7U24WTG8yf9AKiZgk2K4/lines", "data"=>[{"id"=>"ii_102r7U24WTG8yf9AtniOgOuD", "object"=>"line_item", "type"=>"invoiceitem", "livemode"=>true, "amount"=>20000, "currency"=>"cad", "proration"=>false, "period"=>{"start"=>1383240514, "end"=>1383240514}, "quantity"=>nil, "plan"=>nil, "description"=>"4 Hours of Work on OntarioUPC.com", "metadata"=>{}}]}, "subtotal"=>20000, "total"=>20000, "customer"=>"cus_2r1bXf3dZ6DnMV", "object"=>"invoice", "attempted"=>false, "closed"=>false, "paid"=>false, "livemode"=>true, "attempt_count"=>0, "amount_due"=>20000, "currency"=>"cad", "starting_balance"=>0, "ending_balance"=>nil, "next_payment_attempt"=>1383244137, "charge"=>nil, "discount"=>nil, "application_fee"=>nil}, "previous_attributes"=>{"closed"=>true, "next_payment_attempt"=>nil}}, "object"=>"event", "pending_webhooks"=>2, "request"=>"iar_2r9VvYWKDABl9H", "user_id"=>"acct_102in424WTG8yf9A", "subdomain"=>"www", "stripe"=>{"id"=>"evt_102r9V24WTG8yf9A8lnhd1Go", "created"=>1383248012, "livemode"=>true, "type"=>"invoice.updated", "data"=>{"object"=>{"date"=>1383240537, "id"=>"in_102r7U24WTG8yf9AKiZgk2K4", "period_start"=>1383240537, "period_end"=>1383240537, "lines"=>{"object"=>"list", "count"=>1, "url"=>"/v1/invoices/in_102r7U24WTG8yf9AKiZgk2K4/lines", "data"=>[{"id"=>"ii_102r7U24WTG8yf9AtniOgOuD", "object"=>"line_item", "type"=>"invoiceitem", "livemode"=>true, "amount"=>20000, "currency"=>"cad", "proration"=>false, "period"=>{"start"=>1383240514, "end"=>1383240514}, "quantity"=>nil, "plan"=>nil, "description"=>"4 Hours of Work on OntarioUPC.com", "metadata"=>{}}]}, "subtotal"=>20000, "total"=>20000, "customer"=>"cus_2r1bXf3dZ6DnMV", "object"=>"invoice", "attempted"=>false, "closed"=>false, "paid"=>false, "livemode"=>true, "attempt_count"=>0, "amount_due"=>20000, "currency"=>"cad", "starting_balance"=>0, "ending_balance"=>nil, "next_payment_attempt"=>1383244137, "charge"=>nil, "discount"=>nil, "application_fee"=>nil}, "previous_attributes"=>{"closed"=>true, "next_payment_attempt"=>nil}}, "object"=>"event", "pending_webhooks"=>2, "request"=>"iar_2r9VvYWKDABl9H", "user_id"=>"acct_102in424WTG8yf9A"}}
  end
end
