class AddStripeTokenToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :customer_token, :string
  end
end
