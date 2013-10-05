@selectedNav = ->
  $(".nav a").each ->
    if window.location.pathname == $(this).attr("href")
      li = $(this).closest("li")
      li.addClass("selected")
      li.parents("li").addClass("parent_of_selected")