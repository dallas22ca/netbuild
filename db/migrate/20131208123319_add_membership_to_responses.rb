class AddMembershipToResponses < ActiveRecord::Migration
  def change
    add_reference :responses, :membership, index: true
  end
end
