cache [@website, "feed"] do
  xml.instruct! :xml, :version => "1.0" 
  xml.rss :version => "2.0" do
    xml.channel do
      xml.title @website.title
      xml.link feed_url

      @website.pages.not_roots.order("published_at desc").each do |page|
        xml.item do
          xml.title page.title
          # xml.description page.blocks.map{|b|render(b)}.join("\n\n")
          xml.pubDate page.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")
          xml.link "#{root_url}#{page.path[1..-1]}"
          xml.guid "#{root_url}#{page.path[1..-1]}"
        end
      end
    end
  end
end