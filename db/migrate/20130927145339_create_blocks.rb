class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.belongs_to :wrapper, index: true
      t.string :genre
      t.hstore :details

      t.timestamps
    end
    add_hstore_index :blocks, :details
  end
end
