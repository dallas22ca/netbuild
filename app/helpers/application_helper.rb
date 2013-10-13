module ApplicationHelper
  def find_renders(content)
    content.gsub(/\{\{ render(.*?) \}\}/) { |t| "{{ #{t.strip.parameterize} }}" }
  end
end
