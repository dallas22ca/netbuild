json.array!(@responses) do |response|
  json.extract! response, :block_id, :data, :contact_id, :website_id
  json.url response_url(response, format: :json)
end
