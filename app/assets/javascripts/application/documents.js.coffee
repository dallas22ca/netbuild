$(window).on "keypress", (e) ->
  if $("#document_body").length
    code = e.keyCode or e.which
    if code == 115 && (e.ctrlKey || e.metaKey)
      e.preventDefault()
      $("#document_body").val window.editor.getValue()
      $("#new_document, .edit_document").submit()

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
      styleActiveLine: true
      theme: "solarized dark"
      mode: "css"