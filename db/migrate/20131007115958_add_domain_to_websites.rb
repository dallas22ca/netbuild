class AddDomainToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :domain, :string, default: ""
    add_index :websites, :domain
  end
end
