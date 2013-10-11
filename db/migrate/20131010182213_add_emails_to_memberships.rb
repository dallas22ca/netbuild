class AddEmailsToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :username, :string
    add_column :memberships, :forward_to, :string
    add_column :memberships, :has_email_account, :boolean, default: false
  end
end
