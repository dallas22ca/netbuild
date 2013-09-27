json.array!(@documents) do |document|
  json.extract! document, :theme_id, :name, :extension, :body
  json.url document_url(document, format: :json)
end
