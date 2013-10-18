@setColours = ->
  if $("#primary_colorpicker").length
    $("#primary_colorpicker").ColorPicker
      color: rgbToHex($("#primary_colorpicker").val())
      onChange: (hsb, hex, rgb) ->
        $("#topbar").css "background", "##{hex}"
        $("#primary_colorpicker").val "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"
        $("#primary_colorpicker").css "background", "##{hex}"
    
    $("#secondary_colorpicker").ColorPicker
      color: rgbToHex($("#secondary_colorpicker").val())
      onChange: (hsb, hex, rgb) ->
        $("#topbar").css "border-color", "##{hex}"
        $("#secondary_colorpicker").val "rgb(#{rgb.r}, #{rgb.g}, #{rgb.b})"
        $("#secondary_colorpicker").css "background", "##{hex}"
    
    $("#primary_colorpicker, #secondary_colorpicker").trigger("change")
  
componentToHex = (c) ->
  hex = parseFloat(c).toString(16)
  r = if hex.length == 1 then "0#{hex}" else hex
  r

rgbToHex = (rgb) ->
  rs = rgb.replace(")", "").replace("rgb(", "").replace(" ", "").split(",")
  r = componentToHex(rs[2])
  hex = "##{componentToHex(rs[0])}#{componentToHex(rs[1])}#{componentToHex(rs[2])}"
  hex