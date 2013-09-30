class AddOrdinalToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :ordinal, :integer, default: 1000
  end
end
