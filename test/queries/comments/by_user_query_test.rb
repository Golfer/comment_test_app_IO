require "test_helper"

module Comments
  class ByUserQueryTest < ActiveSupport::TestCase
    test "returns a user's comments newest first" do
      user = create(:user)
      older = create(:comment, user: user, body: "older", created_at: 2.days.ago)
      newer = create(:comment, user: user, body: "newer", created_at: 1.hour.ago)
      create(:comment, body: "someone else")

      result = ByUserQuery.call(user: user)
      assert_equal [ newer.id, older.id ], result.map(&:id)
    end
  end
end
