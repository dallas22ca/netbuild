$(document).on "click", ".show_media", ->
  gallery = $("#media_gallery")
  url = gallery.data("url")
  gallery.fadeToggle(150)
  $.getScript url
  false