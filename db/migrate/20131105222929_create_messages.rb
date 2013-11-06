class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :website, index: true
      t.belongs_to :user, index: true
      t.text :to
      t.text :subject
      t.text :plain

      t.timestamps
    end
  end
end
