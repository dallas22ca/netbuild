class AddResizedToMedia < ActiveRecord::Migration
  def change
    add_column :media, :resized, :boolean, default: false
  end
end
