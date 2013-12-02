class AddAllowSignupsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :allow_signups, :boolean, default: false
  end
end
