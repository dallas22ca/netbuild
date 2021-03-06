$(window).bind "beforeunload", ->
  "You have unsaved changes." if window.midedit #!timeTravel.active && 

$(document).on "click", ".nav a", ->
  if window.midedit #!timeTravel.active &&
    if !confirm "You have unsaved changes. Are you sure you want to continue?"
      false

$(document).on
  mouseenter: ->
    $(this).addClass "hover"
  mouseleave: ->
    $(this).removeClass "hover"
, ".contenteditable"

$(document).on "keyup", "[data-title]", ->
  page_id = $("[data-page_id]").data("page_id")
  $(".page[data-id='#{page_id}'] a").text $(this).text()

$(document).on "keydown", "[contenteditable]", (e) ->
  window.midedit = true
  
  if !$(this).is("ul") && !$(this).is("ol")
    code = ((if e.keyCode then e.keyCode else e.which))
    if code is 13
      document.execCommand "insertHTML", false, "<br><br>"
      false

$(document).on "click", ".contenteditable", ->
  $(this).attr("contenteditable", true).focus()

$(document).on "click", "html, body", (e) ->
  if !$(e.target).hasClass("contenteditable") && !$(e.target).closest(".contenteditable").length
    $("[contenteditable]").removeAttr "contenteditable"

$(document).on "blur", "[contenteditable]", ->
  $("body").addClass "mid_edit"
  
  if $(this).closest(".block").length
    details = {}
    details.style = $(this).get(0).tagName.toLowerCase()
    details.content = $(this).html()
    $(this).closest(".block").attr("data-details", JSON.stringify(details))

  setTimeout ->
    if !$("*:focus").length && $(".mid_edit").length
      $("[contenteditable]").removeAttr "contenteditable"
      $("body").removeClass "mid_edit"
      createSnapshot()
  , 111

$(document).on "click", "[data-action]", (e) ->
  action = $(this).data("action")
  $("body").removeClass "mid_edit"
  document.execCommand action, false
  createSnapshot()
  false

$(document).on "click", ".publish", ->
  publish()
  false

@publish = ->
  url = $(".publish").data("url")
  blocks = []
  wrappers = []
  
  window.midedit = false
  timeTravel.saved_id = timeTravel.current
  localStorage.setItem "page_#{timeTravel.page_id}_saved_id", timeTravel.saved_id
  pages = if $(".nav.roots").length then $(".nav.roots:first").sortable("toArray") else []
  
  $("#timetravel").find(".wrapper").each ->
    wrapper_id = $(this).data("id")
    n = 0
    
    $(this).find(".block").each ->
      if $(this).parents(".block").length
        wrapper_id = $(this).closest(".wrapper").data("id")
      
      unless $(this).parents(".block").length
        block = {}
        block.id = $(this).data("id")
        block.wrapper_id = wrapper_id
        block.genre = $(this).data("genre")
        block.delete = $(this).hasClass("pending_delete")
        block.ordinal = n
        block.data = $.parseJSON($(this).attr("data-details"))
        blocks.push block
        n += 1
  
  $.post url,
    "_method": "patch"
    "page_id": $("body").data("page_id")
    "blocks": blocks
    "title": $("#timetravel [data-title]").text()
    "website[warnings]": ""
    "pages": pages

unload = ->
  window.midedit = false
  $("#loading").show()

load = ->
  selectedNav()
  # timeTravel.init() if window && window["localStorage"] != null
  createSnapshot() unless timeTravel.active
  $("#s3-uploader").S3Uploader() if $("#s3-uploader").length
  $("#loading").fadeOut()

$ ->
  load()
  
document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load