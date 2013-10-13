$(document).on
  mouseenter: ->
    $(this).find(".delete").show()
  mouseleave: ->
    $(this).find(".delete").hide()
, ".document"


@setCodeMirror = ->
  if $("#document_body").length
    window.editor = CodeMirror.fromTextArea $("#document_body")[0], 
      matchBrackets: true
      smartIndent: true
      lineWrapping: true
      lineNumbers: true
      theme: "lesser-dark"
      mode: "css"