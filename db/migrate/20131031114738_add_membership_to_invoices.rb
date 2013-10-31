class AddMembershipToInvoices < ActiveRecord::Migration
  def change
    add_reference :invoices, :membership, index: true
    add_column :memberships, :customer_token, :string
    add_column :memberships, :card_token, :string
    add_column :memberships, :last_4, :integer
    add_column :websites, :stripe_access_token, :string
    add_column :websites, :stripe_user_id, :string
    add_column :invoices, :netbuild_website_id, :integer
    add_index :invoices, :netbuild_website_id
  end
end
