class CreateAddons < ActiveRecord::Migration
  def change
    create_table :addons do |t|
      t.string :name
      t.string :permalink
      t.integer :price
      t.boolean :quantifiable
      t.boolean :available

      t.timestamps
    end
  end
end
