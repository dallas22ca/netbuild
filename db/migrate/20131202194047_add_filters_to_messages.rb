class AddFiltersToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :filters, :text
  end
end
