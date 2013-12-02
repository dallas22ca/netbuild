$(document).on "click", "#membership_has_email_account", ->
  Members.customEmail()

@Members =
  init: ->
    Members.customEmail()

  customEmail: ->
    if $("#membership_has_email_account").is(":checked")
      $(".custom_email_form").show()
    else
      $(".custom_email_form").hide()