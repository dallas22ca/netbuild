class CreateWrappers < ActiveRecord::Migration
  def change
    create_table :wrappers do |t|
      t.string :identifier
      t.belongs_to :page, index: true
      t.belongs_to :website, index: true

      t.timestamps
    end
  end
end
