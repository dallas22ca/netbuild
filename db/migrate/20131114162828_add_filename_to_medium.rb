class AddFilenameToMedium < ActiveRecord::Migration
  def change
    add_column :media, :filename, :string
  end
end
