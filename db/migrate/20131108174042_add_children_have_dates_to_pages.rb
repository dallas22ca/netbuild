class AddChildrenHaveDatesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :children_have_dates, :boolean, default: false
  end
end
