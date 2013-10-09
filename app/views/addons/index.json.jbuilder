json.array!(@addons) do |addon|
  json.extract! addon, :name, :permalink, :price, :quantifiable, :available
  json.url addon_url(addon, format: :json)
end
