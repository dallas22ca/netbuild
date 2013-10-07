json.array!(@media) do |medium|
  json.extract! medium, :website_id, :path, :name, :description, :width, :height, :size, :user_id, :extension
  json.url medium_url(medium, format: :json)
end
