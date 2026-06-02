require "test_helper"

class FakeCommentsGenerationWorkerTest < ActiveSupport::TestCase
  test "generates the requested number of comments" do
    user = create(:user)
    FakeCommentsGenerationWorker.new.perform(50, [ user.id ])
    assert_equal 50, Comment.count
  end

  test "builds a nested tree with roots and replies" do
    user = create(:user)
    FakeCommentsGenerationWorker.new.perform(300, [ user.id ])
    assert Comment.roots.exists?, "expected some root comments"
    assert Comment.where("ancestry_depth > 0").exists?, "expected some nested replies"
  end

  test "no-ops for a non-positive count" do
    assert_no_difference "Comment.count" do
      FakeCommentsGenerationWorker.new.perform(0)
    end
  end

  test "creates users when none are provided" do
    FakeCommentsGenerationWorker.new.perform(10)
    assert_equal 10, Comment.count
  end
end
