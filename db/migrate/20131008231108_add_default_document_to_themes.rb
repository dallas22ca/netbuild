class AddDefaultDocumentToThemes < ActiveRecord::Migration
  def change
    add_reference :themes, :default_document, index: true
  end
end
