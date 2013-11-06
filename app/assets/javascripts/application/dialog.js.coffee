$(document).on "click", "#dialog_overlay", ->
  Dialog.close()

@Dialog =
  open: (id) ->
    $("##{id}").fadeIn 150
    $("#dialog_overlay").fadeIn 150
  
  close: ->
    $(".dialog").fadeOut 150
    $("#dialog_overlay").fadeOut 150