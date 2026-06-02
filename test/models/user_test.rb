require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "factory is valid" do
    assert build(:user).valid?
  end

  test "requires a name" do
    user = build(:user, name: "")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "online? is false when never seen" do
    assert_not build(:user, last_seen_at: nil).online?
  end

  test "online? is true when seen within the window" do
    assert create(:user, last_seen_at: 1.minute.ago).online?
  end

  test "online? is false when seen long ago" do
    assert_not create(:user, last_seen_at: 10.minutes.ago).online?
  end

  test "clear_presence! removes online status" do
    user = create(:user, last_seen_at: Time.current)
    user.clear_presence!
    assert_nil user.reload.last_seen_at
    assert_not user.online?
  end

  test "touch_presence! updates last_seen_at" do
    user = create(:user, last_seen_at: nil)
    user.touch_presence!
    assert_not_nil user.reload.last_seen_at
  end

  test "display_name falls back to email local part" do
    user = build(:user, name: "", email: "alice@example.com")
    assert_equal "alice", user.display_name
  end

  test "display_name prefers the name" do
    assert_equal "Bob", build(:user, name: "Bob").display_name
  end

  test "initials uses first two name parts" do
    assert_equal "JD", build(:user, name: "John Doe").initials
  end

  test "user serializer exposes the public fields" do
    user = create(:user, name: "John Doe", last_seen_at: 1.minute.ago)
    json = Users::UserSerializer.call(user)
    assert_equal user.id, json[:id]
    assert_equal "John Doe", json[:name]
    assert_equal "JD", json[:initials]
    assert json[:online]
    assert_equal user.comments_count, json[:comments_count]
  end
end
