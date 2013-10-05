$(document).on "click", "[data-snapshot]", ->
  action = $(this).data("snapshot")
  useSnapshot action
  false

$(document).on "click", ".clear_timetravel", ->
  $(".clear_timetravel").hide()
  timeTravel.db().transaction (tx) ->
    tx.executeSql "DELETE FROM snapshots WHERE page_id = ?", [timeTravel.page_id]
    useSnapshot false, timeTravel.saved_id
  false

@timeTravel =
  init: ->
    timeTravel.page_id = $("body").data("page_id")
    timeTravel.saved_id = localStorage.getItem "page_#{timeTravel.page_id}_saved_id"
    timeTravel.db().transaction (tx) ->
      tx.executeSql "CREATE TABLE IF NOT EXISTS snapshots(id INTEGER PRIMARY KEY ASC, html TEXT, page_id INTEGER)", []
      
    timeTravel.active = true
    
    timeTravel.db().transaction (tx) ->
      tx.executeSql "SELECT * FROM snapshots WHERE page_id = ? ORDER BY id DESC", [timeTravel.page_id], (tx, results) ->
        if results.rows.length
          if results.rows.length > 10
            timeTravel.db().transaction (x) ->
              ids = [5, 6]
              x.executeSql "DELETE FROM snapshots WHERE id in (?)", [ids]

          snapshot = results.rows.item(0)
          timeTravel.newest_id = results.rows.item(0).id
          timeTravel.oldest_id = results.rows.item(results.rows.length - 1).id

          if parseInt(timeTravel.saved_id) == timeTravel.newest_id
            timeTravel.current = snapshot.id
            loadBlocks()
            disableHistoryButtons()
          else
            useSnapshot false, timeTravel.newest_id
        
        else
          if createSnapshot()
            loadBlocks()
            disableHistoryButtons()

  db: ->
    openDatabase "TimeTravel", "1.0", "Undo and Redo til your heart is content", 5 * 1024 * 1024
  active: false
  current: 0
  newest_id: 0
  oldest_id: 0
  saved_id: 0
  page_id: 0

@createSnapshot = ->
  if timeTravel.active
    $(".clear_timetravel").show()
    timeTravel.db().transaction (tx) ->
      tx.executeSql "INSERT INTO snapshots(html, page_id) VALUES (?, ?)", [$("#timetravel").html(), $("body").data("page_id")], (tx, results) ->
        timeTravel.current = results.insertId
        timeTravel.newest_id += 1
        loadBlocks()
        disableHistoryButtons()
  else
    html = $("<div>").addClass "snapshot current"
    html.html $("#timetravel").html()
    $(".clear_timetravel").hide()
    $("#snapshots .current").removeClass "current"
    $("#snapshots").append html
    
    loadBlocks()
    disableHistoryButtons()

@useSnapshot = (action, id = false) ->
  if timeTravel.active
    snapshot = false
    
    if action == false
      timeTravel.db().transaction (tx) ->
        tx.executeSql "SELECT * FROM snapshots WHERE page_id = ? AND id = ? LIMIT 1", [timeTravel.page_id, id], (tx, results) ->
          if results.rows.length
            snapshot = results.rows.item(0)
            $("#timetravel").html snapshot.html
            timeTravel.current = snapshot.id
            loadBlocks()
            disableHistoryButtons()
    else
      if action == "Undo"
        timeTravel.db().transaction (tx) ->
          tx.executeSql "SELECT * FROM snapshots WHERE page_id = ? AND id < ? ORDER BY id DESC LIMIT 1", [timeTravel.page_id, timeTravel.current], (tx, results) ->
            if results.rows.length
              snapshot = results.rows.item(0)
              timeTravel.current = snapshot.id
              $("#timetravel").html snapshot.html
              loadBlocks()
              disableHistoryButtons()
      else
        timeTravel.db().transaction (tx) ->
          tx.executeSql "SELECT * FROM snapshots WHERE page_id = ? and id > ? ORDER BY id ASC LIMIT 1", [timeTravel.page_id, timeTravel.current], (tx, results) ->
            if results.rows.length
              snapshot = results.rows.item(0)
              timeTravel.current = snapshot.id
              $("#timetravel").html snapshot.html
              loadBlocks()
              disableHistoryButtons()
  else    
    if action == "Undo"
      if $("#snapshots .current").prev().length
        $("#snapshots .current").removeClass("current").prev().addClass("current")
    else
      if $("#snapshots .current").next().length
        $("#snapshots .current").removeClass("current").next().addClass("current")
    $("#timetravel").html $("#snapshots .current").html()
  
    loadBlocks()
    disableHistoryButtons()

disableHistoryButtons = ->
  if timeTravel.active
    index = timeTravel.current
    newest = timeTravel.newest_id
    oldest = timeTravel.oldest_id
    window.midedit = false
  else
    index = $("#snapshots .current").index()
    newest = $("#snapshots .snapshot").length - 1
    oldest = 0
    window.midedit = true if index != oldest

  if index == oldest
    $("[data-snapshot=Undo]").closest("li").addClass("disabled")
  else
    $("[data-snapshot=Undo]").closest("li").removeClass("disabled")
  
  if index == newest
    $("[data-snapshot=Redo]").closest("li").addClass("disabled")
  else
    $("[data-snapshot=Redo]").closest("li").removeClass("disabled")