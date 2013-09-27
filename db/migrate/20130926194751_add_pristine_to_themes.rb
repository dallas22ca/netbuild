class AddPristineToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :pristine, :boolean, default: false
  end
end
