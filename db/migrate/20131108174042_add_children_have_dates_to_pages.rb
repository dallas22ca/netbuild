class AddChildrenHaveDatesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :children_have_dates, :boolean, default: false
    add_column :pages, :published_at, :datetime
  end
end
