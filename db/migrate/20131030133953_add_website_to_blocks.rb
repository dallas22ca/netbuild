class AddWebsiteToBlocks < ActiveRecord::Migration
  def change
    add_reference :blocks, :website, index: true
  end
end
