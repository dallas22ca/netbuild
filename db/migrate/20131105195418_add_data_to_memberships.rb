class AddDataToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :data, :hstore
    add_hstore_index :memberships, :data
  end
end
