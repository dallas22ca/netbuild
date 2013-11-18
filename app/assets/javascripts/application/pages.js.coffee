$(document).on "keyup", "#page_title", ->
  if !$("#page_permalink").hasClass("set")
    title = $(this).val()
    $("#page_permalink").val URLify(title)

$(document).on "keyup", "#page_permalink", ->
  $(this).addClass("set")
  

URLify = (s) ->
  removelist = ["a", "an", "as", "at", "before", "but", "by", "for", "from", "is", "in", "into", "like", "of", "off", "on", "onto", "per", "since", "than", "the", "this", "that", "to", "up", "via", "with"]
  r = new RegExp("\\b(" + removelist.join("|") + ")\\b", "gi")
  s = s.replace(r, "")
  s = s.replace(/[^-\w\s]/g, "") # remove unneeded chars
  s = s.replace(/^\s+|\s+$/g, "") # trim leading/trailing spaces
  s = s.replace(/[-\s]+/g, "-") # convert spaces to hyphens
  s = s.toLowerCase() # convert to lowercase