class AddSubscriptionPageToWebsites < ActiveRecord::Migration
  def change
    Website.find_each do |w|
      if w.theme.default_document_id && w.pages.where(permalink: "subscriptions").empty?
        w.pages.create!(
          title: "Subscriptions",
          permalink: "subscriptions",
          description: "Manage your subscriptions",
          visible: false,
          deleteable: false,
          ordinal: 994,
          document_id: w.theme.default_document_id
        )
      end
    end
  end
end
