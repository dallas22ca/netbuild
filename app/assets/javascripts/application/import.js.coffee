@Importer =
  init: ->
    if $("#importer").length
      $("#importer").S3Uploader
        additional_data:
          "medium[import]": true
        before_add: ->
          alert "Uploading and parsing your list..."
          true