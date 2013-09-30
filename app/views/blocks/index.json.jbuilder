json.array!(@blocks) do |block|
  json.extract! block, :website_id, :parent, :genre, :details
  json.url block_url(block, format: :json)
end
