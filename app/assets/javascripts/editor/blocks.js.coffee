$(document).on "submit", ".widget_editor", ->
  block_id = $(this).find(".block_id").val()
  block = {}
  
  $(this).find("select, input, textarea").each ->
    name = $(this).attr("name")
    value = $(this).val()
    
    if typeof name != "undefined" && name != "utf8" && name != "block_id" && name != "commit"
      if $(this).is("select") && typeof value == "string"
        value = [value]
      block[name.replace("[]", "")] = value
  
  $("#widget_editor_overlay").fadeOut(150)
  $(this).fadeOut()
  
  if $("#timetravel #block_#{block_id}").attr("data-details", JSON.stringify(block))
    $.getScript $("#timetravel #block_#{block_id}").data("url")
    window.midedit = true
    createSnapshot()
  false

$(document).on "click", ".edit", ->
  editBlock $(this).closest(".block")
  false
  
$(document).on "click", ".widget_editor input:checkbox", ->
  $(this).val $(this).is(":checked")

$(document).on "click", ".widget_editor .cancel", ->
  $(".widget_editor").fadeOut(150)
  $("#widget_editor_overlay").fadeOut(150)
  $(".handle, .delete, .edit").remove()
  false

$(document).on "click", ".delete", ->
  block = $(this).closest(".block")
  block.addClass("pending_delete")
  createSnapshot()
  false

$(document).on
  mouseenter: ->
    if !$(".placeholder").length && !$(".handle:visible").length && !$("*:focus").length && !$(".widget_editor:visible").length
      handle = $("<i>").addClass("icon-move handle")
      trash = $("<i>").addClass("icon-trash delete")
      edit = $("<i>").addClass("icon-cog edit")
      genre = $(this).data("genre")
      
      handle.css("width", $(this).width())
      handle.prependTo $(this)
      trash.prependTo $(this)

      unless genre == "h3" || genre == "h4" || genre == "p"
        edit.prependTo $(this)
  mouseleave: ->
    if !$(".placeholder").length && !$(".widget_editor:visible").length
      $(".handle, .delete, .edit").remove()
  click: ->
    $(".handle, .delete, .edit").remove()
, "#timetravel .block"

@showNoWrappers = ->
  $(".wrapper").each ->
    unless $(this).children(".block:visible").length
      $(this).addClass("droppable")

@editBlock = (block) ->
  window.midedit = true
  genre = block.data("genre")
  editor = $(".widget_editor[data-genre='#{genre}']")
  
  $(".widget_editor").hide()
  $("#widget_editor_overlay").fadeIn(150)
  
  top = block.position().top - 35
  left = block.position().left + block.outerWidth() + 20
  left = block.position().left - block.outerWidth() - 70 if left + editor.width() > $(window).width()

  for field,value of $.parseJSON(block.attr("data-details"))
    if editor.find(".#{field}").is("select")
      editor.find(".#{field} option").removeAttr("selected")
      editor.find(".#{field} option").each ->
        try value = $.parseJSON(value)
        if $.inArray($(this).text(), value) != -1
         $(this).attr("selected", true)
    else if editor.find(".#{field}").is(":checkbox")
      if value == "true"
        editor.find(".#{field}").attr("checked", true)
      else
        editor.find(".#{field}").removeAttr("checked")
    else
      editor.find(".#{field}").val value
  
  editor.find(".block_id").val block.data("id")
  editor.css
    top: top
    left: left
  editor.fadeIn(150)
  
  if $(".chosen-container").length
    $(".tags").trigger("chosen:updated")
  else
    $(".tags").chosen
      width: "100%"
      search_contains: true
      
@loadBlocks = ->
  showNoWrappers()
  
  $(".widget_editor").draggable
    handle: "h3"
  
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
      showNoWrappers()
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
    update: (e, ui) ->
      if this == ui.item.parent()[0]
        createSnapshot()