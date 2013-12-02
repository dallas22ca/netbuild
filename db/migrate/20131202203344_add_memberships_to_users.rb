class AddMembershipsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :data, :hstore
    add_column :users, :website_id, :integer
    add_column :users, :security, :string
    add_column :users, :username, :string
    add_column :users, :has_email_account, :boolean
    add_column :users, :forward_to, :string
    add_column :users, :customer_token, :string
    add_column :users, :card_token, :string
    add_column :users, :last_4, :string
    add_index :users, :website_id
  end
end
