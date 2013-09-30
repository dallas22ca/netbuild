class CreateWrappers < ActiveRecord::Migration
  def change
    create_table :wrappers do |t|
      t.string :identifier
      t.belongs_to :page, index: true

      t.timestamps
    end
    
    add_index :blocks, :identifier
  end
end
