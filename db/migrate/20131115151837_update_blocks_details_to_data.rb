class UpdateBlocksDetailsToData < ActiveRecord::Migration
  def change
    Block.all.find_each do |b|
      b.data = b.details
      b.save
    end
  end
end
