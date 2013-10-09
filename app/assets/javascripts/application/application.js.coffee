unload = ->
  $("#loading").show()

load = ->
  Stripe.setPublishableKey $("meta[name='stripe-key']").attr("content")
  $("#loading").fadeOut()

$ ->
  load()
  
document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load