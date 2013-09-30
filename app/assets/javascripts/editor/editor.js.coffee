$(window).bind "beforeunload", ->
  "You have unsaved changes." if !timeTravel.active && window.midedit

$(document).on
  mouseenter: ->
    $(this).addClass "hover"
  mouseleave: ->
    $(this).removeClass "hover"
, ".contenteditable"

$(document).on "keydown", "[contenteditable]", (e) ->
  if !$(this).is("ul") && !$(this).is("ol")
    code = ((if e.keyCode then e.keyCode else e.which))
    if code is 13
      document.execCommand "insertHTML", false, "<br>"
      false

$(document).on "click", ".contenteditable", ->
  $(this).attr("contenteditable", true).focus()

$(document).on "click", "html, body", (e) ->
  if !$(e.target).hasClass("contenteditable") && !$(e.target).closest(".contenteditable").length
    $("[contenteditable]").removeAttr "contenteditable"

$(document).on "blur", "[contenteditable]", ->
  $("body").addClass "mid_edit"

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

$(document).on "click", ".edit", ->
  block = $(this).closest(".block")
  genre = block.data("genre")
  alert genre
  false

$(document).on "click", ".delete", ->
  block = $(this).closest(".block")
  block.addClass("pending_delete")
  createSnapshot()
  false

$(document).on "click", ".publish", ->
  blocks = []
  
  $("#timetravel").find(".blocks").each ->
    parent = $(this).data("parent")
    n = 0
    
    $(this).find(".block").each ->
      block = {}
      block.id = $(this).data("id")
      block.parent = parent
      block.genre = $(this).data("genre")
      block.delete = $(this).hasClass("pending_delete")
      block.ordinal = n
      block.details = {}
      
      if block.genre == "p" || block.genre == "h3" || block.genre == "h4" || block.genre == "blockquote"
        block.details.content = $(this).find(".contenteditable").html()
      else if block.genre == "img"
        block.details.src = $(this).find("img").attr("src")
        block.details.href = $(this).find("a").attr("href")
      else if block.genre == "forms"
        block.details.style == $(this).data("style")
      else if block.genre == "events"
        block.details.style == $(this).data("style")
      else if block.genre == "social"
        block.details.style == $(this).data("style")
      else if block.genre == "finance"
        block.details.style == $(this).data("style")
      
      blocks.push block
      n += 1
  
  window.midedit = false

  $.post "/save.js",
    page_id: $("body").data("page_id")
    blocks: blocks
    pages: $(".nav.roots:first").sortable("toArray")

unload = ->
  $("#loading").show()
  
$(document).on "click", ".nav a", ->
  if !timeTravel.active && window.midedit
    if !confirm "You have unsaved changes. Are you sure you want to continue?"
      false

load = ->
  $("#loading").fadeOut()
  
  # timeTravel.init() if window && window["localStorage"] != null
  createSnapshot() unless timeTravel.active

$ ->
  load()
  
document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load