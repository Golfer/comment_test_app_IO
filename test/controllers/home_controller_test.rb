require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows the landing page for a guest" do
    get root_path
    assert_response :success
  end

  test "routes a signed-in user to their chats shell" do
    sign_in create(:user)
    get root_path
    assert_response :success
  end
end
