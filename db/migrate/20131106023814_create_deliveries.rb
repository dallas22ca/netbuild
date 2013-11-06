class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.belongs_to :message, index: true
      t.belongs_to :membership, index: true

      t.timestamps
    end
  end
end
