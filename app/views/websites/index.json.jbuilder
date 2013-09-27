json.array!(@websites) do |website|
  json.extract! website, :title, :permalink, :theme_id
  json.url website_url(website, format: :json)
end
