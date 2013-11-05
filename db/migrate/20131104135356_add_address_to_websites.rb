class AddAddressToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :address, :text
    add_column :websites, :invoice_blurb, :text
  end
end
