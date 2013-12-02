class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name
      t.string :permalink
      t.string :data_type

      t.timestamps
    end
    add_index :fields, :permalink
  end
end
