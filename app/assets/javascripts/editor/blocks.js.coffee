$(document).on
  mouseenter: ->
    if !$(".placeholder").length && !$("*:focus").length
      handle = $("<i>").addClass("icon-move handle")
      trash = $("<i>").addClass("icon-trash delete")
      edit = $("<i>").addClass("icon-cog edit")
      handle.css("width", $(this).width())
      handle.prependTo $(this)
      edit.prependTo $(this)
      trash.prependTo $(this)
  mouseleave: ->
    if !$(".placeholder").length
      $(".handle, .delete, .edit").remove()
  click: ->
    $(".handle, .delete, .edit").remove()
, "#timetravel .block"

@showNoWrappers = ->
  $(".wrapper").each ->
    unless $(this).children(".block:visible").length
      $(this).addClass("droppable")

@loadBlocks = ->
  showNoWrappers()
  
  $(".nav:not(.social)").sortable
    placeholder: "drop_placeholder"
    start: (e, ui) ->
      html = $(ui.item).html()
      $(".drop_placeholder").append html
    update: ->
      nav = $(this)
      $(".nav").each ->
        if nav != $(this) && $(this).hasClass("roots")
          $(this).html nav.html()
      createSnapshot()
    
  $("#timetravel .wrapper").sortable
    items: ".block"
    connectWith: ".wrapper"
    placeholder: "placeholder"
    helper: "drop_helper"
    handle: ".handle"
    cancel: "[contenteditable]"
    start: (e, ui) ->
      $("body").addClass("dragging")
      if ui.item.hasClass "draggable"
        type = ui.item.data("type")
        template = $("#templates .#{type}").clone()
        $(".editable_placeholder").append template
        $(ui.item).addClass("editable_helper")
      else
        html = $(ui.item).html()
        $(".placeholder").append(html).addClass(ui.item.attr("class"))
        $(ui.item).addClass("drop_helper")
    stop: (e, ui) ->
      $("body").removeClass("dragging")
      $(".drop_helper").removeClass("drop_helper")
      showNoWrappers()
    update: ->
      createSnapshot()