json.array!(@memberships) do |membership|
  json.extract! membership, :user_id, :website_id, :security
  json.url membership_url(membership, format: :json)
end
