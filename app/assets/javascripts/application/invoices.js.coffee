$(document).on "blur", ".unit_price", ->
  $(this).val parseFloat($(this).val()).toFixed(2)

$(document).on "keyup", ".unit_price, .quantity, #invoice_tax_rate", ->
  Invoices.calcTotals()

$(document).on "click", ".add_line", ->
  line = 
    quantity: 1
    description: ""
    amount: ""
  Invoices.addLine line
  false
  
$(document).on "click", ".delete_line", ->
  if confirm "Are you sure you want to delete this line?"
    $(this).closest("tr").remove()
  false

@Invoices =
  init: ->
    if $("#lines").length
      lines = $("#lines").data("lines")
      $("#lines tbody").html ""
      for line in lines
        Invoices.addLine line
      Invoices.calcTotals()

  addLine: (line) ->
    n = $(".line").length
    amount = (parseFloat(line.amount) / 100).toFixed(2)
    amount = "" if isNaN(amount)
    tr = $("<tr>").addClass("line")
    
    quantity_td = $("<td>")
    quantity = $("<input>").attr("name", "invoice[lines][][quantity]").addClass("quantity").val(line.quantity).appendTo quantity_td
    quantity_td.appendTo tr
    
    description_td = $("<td>")
    description = $("<textarea>").attr("name", "invoice[lines][][description]").addClass("description").text(line.description).appendTo description_td    
    description_td.appendTo tr
    
    unit_price_td = $("<td>")
    unit_price = $("<input>").attr("name", "invoice[lines][][unit_price]").addClass("unit_price").val(line.unit_price).appendTo unit_price_td
    unit_price_td.appendTo tr
    
    amount_td = $("<td>")
    amount = $("<input>").attr("name", "invoice[lines][][amount]").attr("readonly", true).addClass("amount").val(amount).appendTo amount_td
    amount_td.appendTo tr
    
    del_td = $("<td>")
    del_a = $("<a>").addClass("delete_line").attr("href", "#")
    del = $("<i>").addClass("icon-trash").appendTo del_a
    del_a.appendTo del_td
    del_td.appendTo tr
    
    tr.appendTo "#lines tbody"
  
  calcTotals: ->
    tax_rate = parseFloat($("#invoice_tax_rate").val()) / 100
    tax_rate = 0 if isNaN(tax_rate)
    subtotal = 0
    
    $(".line").each ->
      unit_price = parseFloat $(this).find(".unit_price").val()
      quantity = parseFloat $(this).find(".quantity").val()
      val = unit_price * quantity
      val = 0 if isNaN(val)
      subtotal += val
      $(this).find(".amount").val val.toFixed(2)
      
    total = subtotal + (subtotal * tax_rate)
    $("#invoice_subtotal_in_dollars").val subtotal.toFixed(2)
    $("#invoice_total_in_dollars").val total.toFixed(2)