$(document).on "click", ".medium", ->
  form = $("#media_gallery .chosen form")
  id = $(this).data("id")
  src = $(this).data("src")
  small = $(this).data("small")
  description = $(this).data("description")
  name = $(this).data("name")
  tag_list = $(this).data("tag-list")
  url = form.data("url")
  form.attr "action", "#{url}#{id}"
  form.find(".name").val name
  form.find(".description").val description
  form.find(".small").attr "src", small
  form.find(".url").val src
  form.find(".tag_list").val tag_list
  form.find(".delete_medium").attr "href", form.find(".delete_medium").data("url") + id
  $("#media_gallery .chosen form").show()
  false

$(document).on "click", ".media_tags a", ->
  $(this).closest(".media_tags").find("a").removeClass("selected")
  $(this).addClass("selected")
  $("#media_q").val ""
  false

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
  prompt = $(this).data("gallery-prompt")
  formats = $(this).data("gallery-formats")
  alert "Requires prompt" unless prompt.length
  MediaGallery.open(prompt)
  $("#media_gallery").find(".tabs .navigation a[data-tab='library']").click()
  false

$(document).on "click", ".hide_media_gallery", ->
  MediaGallery.close()
  false
  
@MediaGallery =
  open: ->
    $("body").addClass("fixed")
    $("#media_gallery, #media_gallery_overlay").fadeIn(150)
    Tags.update() unless $("#media_gallery .media_tags li").length
    
  close: ->
    $("#media_gallery, #media_gallery_overlay").fadeOut(150)
    $("body").removeClass("fixed")