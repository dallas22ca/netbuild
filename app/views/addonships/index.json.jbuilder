json.array!(@addonships) do |addonship|
  json.extract! addonship, :website_id, :addon_id
  json.url addonship_url(addonship, format: :json)
end
