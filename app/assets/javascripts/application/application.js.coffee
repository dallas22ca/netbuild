$(document).on "keyup", "#primary_colorpicker", ->
	$(this).ColorPickerSetColor $(this).val()

unload = ->
  $("#loading").show()

load = ->
  Stripe.setPublishableKey $("meta[name='stripe-key']").attr("content")
  $("#loading").fadeOut()
  setCodeMirror()
  setColours()
  selectedNav()
  Invoices.init()

$ ->
  load()
  
document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load