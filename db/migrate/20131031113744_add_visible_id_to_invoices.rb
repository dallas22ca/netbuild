class AddVisibleIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :visible_id, :string
    add_index :invoices, :visible_id
  end
end
