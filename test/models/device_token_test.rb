require "test_helper"

class DeviceTokenTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:device_token).valid?
  end

  test "requires a token" do
    assert_not build(:device_token, token: nil).valid?
  end

  test "token is unique" do
    existing = create(:device_token)
    assert_not build(:device_token, token: existing.token).valid?
  end

  test "platform enum" do
    assert build(:device_token, platform: :ios).ios?
    assert build(:device_token, platform: :android).android?
  end
end
