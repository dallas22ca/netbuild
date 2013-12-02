json.array!(@fields) do |field|
  json.extract! field, :name, :permalink, :data_type
  json.url field_url(field, format: :json)
end
