class AddNoteToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :note, :text
  end
end
