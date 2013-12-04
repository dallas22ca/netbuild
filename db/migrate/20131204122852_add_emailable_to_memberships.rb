class AddEmailableToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :emailable, :boolean, default: true
  end
end
