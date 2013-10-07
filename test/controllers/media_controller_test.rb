require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  setup do
    @medium = media(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:media)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create medium" do
    assert_difference('Medium.count') do
      post :create, medium: { description: @medium.description, extension: @medium.extension, height: @medium.height, name: @medium.name, path: @medium.path, size: @medium.size, user_id: @medium.user_id, website_id: @medium.website_id, width: @medium.width }
    end

    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should show medium" do
    get :show, id: @medium
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @medium
    assert_response :success
  end

  test "should update medium" do
    patch :update, id: @medium, medium: { description: @medium.description, extension: @medium.extension, height: @medium.height, name: @medium.name, path: @medium.path, size: @medium.size, user_id: @medium.user_id, website_id: @medium.website_id, width: @medium.width }
    assert_redirected_to medium_path(assigns(:medium))
  end

  test "should destroy medium" do
    assert_difference('Medium.count', -1) do
      delete :destroy, id: @medium
    end

    assert_redirected_to media_path
  end
end
