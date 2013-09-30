class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.belongs_to :website, index: true
      t.integer :parent
      t.string :genre
      t.hstore :details

      t.timestamps
    end
    add_index :blocks, :parent
    add_hstore_index :blocks, :details
  end
end
