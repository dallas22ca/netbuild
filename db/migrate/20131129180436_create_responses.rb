class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.belongs_to :block, index: true
      t.text :data
      t.belongs_to :contact, index: true
      t.belongs_to :website, index: true

      t.timestamps
    end
  end
end
