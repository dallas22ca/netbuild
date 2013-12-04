class PopulateMembershipTokens < ActiveRecord::Migration
  def change
    Membership.find_each do |m|
      m.generate_token
      m.save
    end
  end
end
