class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :title
      t.string :permalink
      t.text :description
      t.boolean :visible, default: true
      t.integer :ordinal
      t.belongs_to :document, index: true
      t.integer :parent_id
      t.integer :website_id

      t.timestamps
    end
    add_index :pages, :parent_id
    add_index :pages, :website_id
    add_index :pages, :permalink
  end
end
