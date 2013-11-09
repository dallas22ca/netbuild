json.extract! @page, :id, :description, :title, :path, :permalink, :published_at
json.children @page.children, :id, :description, :title, :path, :permalink, :published_at