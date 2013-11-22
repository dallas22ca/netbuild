class AddIncludeJsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :include_js, :boolean, default: true
  end
end
