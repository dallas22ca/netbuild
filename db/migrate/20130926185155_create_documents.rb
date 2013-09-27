class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.belongs_to :theme, index: true
      t.string :name
      t.string :extension
      t.text :body

      t.timestamps
    end
  end
end
