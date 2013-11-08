class AddPublishedToPages < ActiveRecord::Migration
  def change
    add_column :pages, :published, :boolean, default: false
    add_column :pages, :published_at, :datetime
  end
end
