require "test_helper"

class DeviceTokensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "create registers a device token" do
    assert_difference "DeviceToken.count", 1 do
      post device_tokens_path, params: { token: "abc123", platform: "ios" }, as: :json
    end
    assert_response :created
  end

  test "create updates the platform for an existing token" do
    post device_tokens_path, params: { token: "abc123", platform: "ios" }, as: :json
    assert_no_difference "DeviceToken.count" do
      post device_tokens_path, params: { token: "abc123", platform: "android" }, as: :json
    end
    assert_equal "android", @user.device_tokens.find_by(token: "abc123").platform
  end

  test "create reassigns a token to the current user" do
    other_user = create(:user)
    create(:device_token, user: other_user, token: "shared-token", platform: :ios)

    assert_no_difference "DeviceToken.count" do
      post device_tokens_path, params: { token: "shared-token", platform: "web" }, as: :json
    end

    token = DeviceToken.find_by!(token: "shared-token")
    assert_equal @user.id, token.user_id
    assert_equal "web", token.platform
    assert_response :created
  end

  test "destroy removes a device token" do
    token = create(:device_token, user: @user)
    assert_difference "DeviceToken.count", -1 do
      delete device_token_path(token)
    end
    assert_response :no_content
  end
end
