$(document).on "click", ".toggle_billing", ->
  text = if $(this).text() == "Update my credit card" then "Don't update my credit card" else "Update my credit card"
  $(this).text text
  $(".billing").toggle()
  false

$(document).on "keyup", "#website_domain", ->
  if !$("[data-customer-token='true']").length
    hideBilling()

$(document).on "submit", ".edit_website", ->
  if $("[data-stripe]:visible").length
    $("input[type=submit]").attr "disabled", true
    Stripe.createToken $(this), stripeResponse
    false

$(document).on "click", ".cancel_subscription", ->
  if confirm "Your website will no longer have any addons and will not be shown at yourdomain.com. Are you sure you want to continue?"
    $(".addon input[type='checkbox']").removeAttr "checked"
    $("#website_domain").val ""
    $(this).closest("form").submit()

@hideBilling = ->
  if $(".billing").length
    if $("#website_domain").val() == ""
      $(".billing").hide()
    else
      $(".billing").show()

stripeResponse = (status, response) ->
  if status == 200
    $("#website_card_token").val response.id
    $(".edit_website")[0].submit()
  else
    alert response.error.message
    $("input[type=submit]").attr "disabled", false