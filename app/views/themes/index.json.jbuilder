json.array!(@themes) do |theme|
  json.extract! theme, :name, :website_id
  json.url theme_url(theme, format: :json)
end
