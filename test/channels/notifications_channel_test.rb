require "test_helper"

class NotificationsChannelTest < ActionCable::Channel::TestCase
  test "subscribes to the per-user notifications stream" do
    user = create(:user)
    stub_connection current_user: user

    subscribe

    assert subscription.confirmed?
    assert_has_stream "notifications_#{user.id}"
  end
end
