json.array!(@deliveries) do |delivery|
  json.extract! delivery, :message_id, :membership_id
  json.url delivery_url(delivery, format: :json)
end
