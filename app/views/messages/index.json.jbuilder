json.array!(@messages) do |message|
  json.extract! message, :website_id, :user_id, :criteria, :subject, :plain
  json.url message_url(message, format: :json)
end
