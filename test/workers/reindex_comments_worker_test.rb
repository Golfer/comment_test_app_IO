require "test_helper"

class ReindexCommentsWorkerTest < ActiveSupport::TestCase
  test "runs without error when search is disabled" do
    create(:comment)
    assert_nothing_raised do
      ReindexCommentsWorker.new.perform
    end
  end
end
