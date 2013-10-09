json.array!(@invoices) do |invoice|
  json.extract! invoice, :website_id, :date, :stripe_id, :period_start, :period_end, :lines, :subtotal, :total, :paid, :attemp_count
  json.url invoice_url(invoice, format: :json)
end
