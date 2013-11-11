$(document).on "click", ".show_tab", ->
  tab = $(this).data("tab")
  $(this).closest(".tabs").find(".navigation a").removeClass "selected"
  $(this).closest(".tabs").find(".tab:not(.#{tab})").hide()
  $(this).addClass "selected"
  $(this).closest(".tabs").find(".#{tab}").show()
  if tab == "library"
    $(".media_q_holder").show()
  else
    $(".media_q_holder").hide()
  false

$(document).on "click", ".show_media_gallery", ->
  MediaGallery.open()
  $("#media_gallery").find(".tabs .navigation a[data-tab='library']").click()
  false

$(document).on "click", ".hide_media_gallery", ->
  MediaGallery.close()
  false
  
@MediaGallery =
  open: ->
    gallery = $("#media_gallery")
    url = gallery.data("url")
    $("body").addClass("fixed")
    gallery.fadeIn(150)
    $("#media_gallery_overlay").fadeIn(150)
    gallery.find(".tab:first a").click()
    unless gallery.find(".medium").length
      $.getScript url
    
  close: ->
    $("#media_gallery, #media_gallery_overlay").fadeOut(150)
    $("body").removeClass("fixed")