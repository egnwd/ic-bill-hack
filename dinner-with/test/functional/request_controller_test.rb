require 'test_helper'

class RequestControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get pay" do
    get :pay
    assert_response :success
  end

end
