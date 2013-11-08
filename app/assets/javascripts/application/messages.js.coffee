$(document).on "change", "#message_to", (e, p) ->
  if typeof p.selected != "undefined"
    $("#membership_checkbox_#{p.selected}").prop "checked", true
  else
    $("#membership_checkbox_#{p.deselected}").prop "checked", false
  
  $(".to_count").text $(".membership_checkbox:checked").length

$(document).on "click", ".membership_checkbox", ->
  $(".to_count").text $(".membership_checkbox:checked").length
  
$(document).on "click", ".compose_with_id", ->
  id = $(this).data("id")

  $("#message_to option").removeAttr "selected"
  $("#message_to option[value=#{id}]").attr "selected", true
  
  if $(".chosen-container").length
    $("#message_to").trigger("chosen:updated")
  else
    $("#message_to").chosen
      width: "100%"
      search_contains: true

$(document).on "click", ".compose_with_selection", ->
  $("#message_to option").removeAttr "selected"
  
  $(".membership_checkbox:checked").each ->
    id = $(this).closest(".membership").data("id")
    $("#message_to option[value=#{id}]").attr "selected", true
  
  if $(".chosen-container").length
    $("#message_to").trigger("chosen:updated")
  else
    $("#message_to").chosen
      width: "100%"
      search_contains: true

  Dialog.open "message"
  false