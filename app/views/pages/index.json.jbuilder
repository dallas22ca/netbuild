json.array!(@pages) do |page|
  json.extract! page, :title, :description, :visible, :ordinal, :document_id, :parent_id
  json.url page_url(page, format: :json)
end
