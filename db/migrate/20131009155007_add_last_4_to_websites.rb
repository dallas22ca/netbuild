class AddLast4ToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :last_4, :integer
  end
end
