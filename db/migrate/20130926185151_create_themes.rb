class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :name
      t.belongs_to :website, index: true

      t.timestamps
    end
  end
end
