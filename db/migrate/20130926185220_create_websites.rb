class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :title
      t.string :permalink
      t.belongs_to :theme, index: true

      t.timestamps
    end
    
    add_index :websites, :permalink
  end
end
