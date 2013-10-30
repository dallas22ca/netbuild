class AddBlockToWrappers < ActiveRecord::Migration
  def change
    add_column :wrappers, :width, :float
    add_reference :wrappers, :block, index: true
  end
end
