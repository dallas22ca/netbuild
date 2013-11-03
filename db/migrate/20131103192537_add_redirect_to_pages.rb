class AddRedirectToPages < ActiveRecord::Migration
  def change
    add_column :pages, :redirect, :string
  end
end
