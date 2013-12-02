class AddWebsiteToFields < ActiveRecord::Migration
  def change
    add_reference :fields, :website, index: true
  end
end
