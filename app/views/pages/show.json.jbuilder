if @page.has_children?
  json.pages @page.children, :id, :description, :title, :path, :permalink, :published_at
else
  json.extract! @page, :id, :description, :title, :path, :permalink, :published_at
end