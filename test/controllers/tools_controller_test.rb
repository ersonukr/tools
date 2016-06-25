require 'test_helper'

class ToolsControllerTest < ActionController::TestCase
  test "should get check_caimpaign" do
    get :check_caimpaign
    assert_response :success
  end

  test "should get download_test_caimpaign" do
    get :download_test_caimpaign
    assert_response :success
  end

end
