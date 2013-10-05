unload = ->
  $("#loading").show()

load = ->
  selectedNav()
  $("#loading").fadeOut()

$ ->
  load()
  
document.addEventListener "page:fetch", unload
document.addEventListener "page:change", load