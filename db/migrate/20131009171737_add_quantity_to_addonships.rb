class AddQuantityToAddonships < ActiveRecord::Migration
  def change
    add_column :addonships, :quantity, :integer
  end
end
