class AddTokenToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :token, :string
  end
end
