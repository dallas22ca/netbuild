class AddPublicAccessToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :public_access, :boolean, default: false
  end
end
