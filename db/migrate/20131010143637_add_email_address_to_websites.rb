class AddEmailAddressToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :free_email_addresses, :integer, default: 2
  end
end
