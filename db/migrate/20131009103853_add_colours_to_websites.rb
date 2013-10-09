class AddColoursToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :primary_colour, :string
    add_column :websites, :secondary_colour, :string
    add_index :websites, :permalink
  end
end
