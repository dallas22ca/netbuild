class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :website, index: true
      t.string :security

      t.timestamps
    end
  end
end
