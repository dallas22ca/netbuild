class AddHeaderToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :header, :text
  end
end
