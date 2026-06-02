require "test_helper"

class CommentsChannelTest < ActionCable::Channel::TestCase
  test "subscribes to the global comments stream" do
    subscribe
    assert subscription.confirmed?
    assert_has_stream "comments"
  end
end
