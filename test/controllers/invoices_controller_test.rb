require 'test_helper'

class InvoicesControllerTest < ActionController::TestCase
  setup do
    @invoice = invoices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      post :create, invoice: { attemp_count: @invoice.attemp_count, date: @invoice.date, lines: @invoice.lines, paid: @invoice.paid, period_end: @invoice.period_end, period_start: @invoice.period_start, stripe_id: @invoice.stripe_id, subtotal: @invoice.subtotal, total: @invoice.total, website_id: @invoice.website_id }
    end

    assert_redirected_to invoice_path(assigns(:invoice))
  end

  test "should show invoice" do
    get :show, id: @invoice
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice
    assert_response :success
  end

  test "should update invoice" do
    patch :update, id: @invoice, invoice: { attemp_count: @invoice.attemp_count, date: @invoice.date, lines: @invoice.lines, paid: @invoice.paid, period_end: @invoice.period_end, period_start: @invoice.period_start, stripe_id: @invoice.stripe_id, subtotal: @invoice.subtotal, total: @invoice.total, website_id: @invoice.website_id }
    assert_redirected_to invoice_path(assigns(:invoice))
  end

  test "should destroy invoice" do
    assert_difference('Invoice.count', -1) do
      delete :destroy, id: @invoice
    end

    assert_redirected_to invoices_path
  end
end
