require "test_helper"

class PresenceChannelTest < ActionCable::Channel::TestCase
  test "subscribing streams presence and announces the user" do
    user = create(:user, last_seen_at: nil)
    stub_connection current_user: user

    assert_broadcasts("presence", 1) do
      subscribe
    end
    assert_has_stream "presence"
    assert_not_nil user.reload.last_seen_at
  end

  test "ping refreshes presence" do
    user = create(:user, last_seen_at: nil)
    stub_connection current_user: user
    subscribe
    user.update_column(:last_seen_at, nil)

    perform :ping

    assert_not_nil user.reload.last_seen_at
  end

  test "unsubscribing announces the user left" do
    user = create(:user)
    stub_connection current_user: user
    subscribe

    assert_broadcasts("presence", 1) do
      unsubscribe
    end
    assert_nil user.reload.last_seen_at
  end
end
