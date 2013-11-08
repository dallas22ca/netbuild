@rgba = (colour, alpha) ->
  colour.replace(")", ", " + alpha + ")").replace("rgb", "rgba")