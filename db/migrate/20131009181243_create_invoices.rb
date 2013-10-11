class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :website, index: true
      t.datetime :date
      t.string :stripe_id
      t.datetime :period_start
      t.datetime :period_end
      t.text :lines
      t.integer :subtotal
      t.integer :total
      t.boolean :paid
      t.integer :attempt_count

      t.timestamps
    end
  end
end
