require 'test_helper'

class AddonshipsControllerTest < ActionController::TestCase
  setup do
    @addonship = addonships(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:addonships)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create addonship" do
    assert_difference('Addonship.count') do
      post :create, addonship: { addon_id: @addonship.addon_id, website_id: @addonship.website_id }
    end

    assert_redirected_to addonship_path(assigns(:addonship))
  end

  test "should show addonship" do
    get :show, id: @addonship
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @addonship
    assert_response :success
  end

  test "should update addonship" do
    patch :update, id: @addonship, addonship: { addon_id: @addonship.addon_id, website_id: @addonship.website_id }
    assert_redirected_to addonship_path(assigns(:addonship))
  end

  test "should destroy addonship" do
    assert_difference('Addonship.count', -1) do
      delete :destroy, id: @addonship
    end

    assert_redirected_to addonships_path
  end
end
