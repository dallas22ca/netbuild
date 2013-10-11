class CreateAddonships < ActiveRecord::Migration
  def change
    create_table :addonships do |t|
      t.belongs_to :website, index: true
      t.belongs_to :addon, index: true
      t.integer :quantity, default: 0
      
      t.timestamps
    end
  end
end
