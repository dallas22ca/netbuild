class AddHomeIdToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :home_id, :integer
    add_index :websites, :home_id
  end
end
