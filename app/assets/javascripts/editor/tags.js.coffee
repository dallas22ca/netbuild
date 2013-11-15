@Tags =
  update: ->
    tags = $("#media_gallery .media_tags")
    url = tags.data("url")
    selected = tags.find(".tag a.selected .name").text()
    
    $.getScript url, ->
      tags.find("a[data-tag='#{selected}']").click()