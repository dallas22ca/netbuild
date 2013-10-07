class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.belongs_to :website, index: true
      t.string :path
      t.string :name
      t.string :description
      t.integer :width
      t.integer :height
      t.integer :size
      t.string :extension

      t.timestamps
    end
  end
end
