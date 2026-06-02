require "test_helper"

module Comments
  class CreateServiceTest < ActiveSupport::TestCase
    setup do
      @author = create(:user)
    end

    test "creates a root comment" do
      assert_enqueued_jobs 1, only: Comments::PostCreateJob do
        result = Comments::CreateService.call(author: @author, body: "hello")
        assert result.success?
        assert result.comment.root?
      end

      assert_enqueued_with(job: Comments::PostCreateJob, queue: "notifications")
    end

    test "creates a reply under a parent" do
      parent = create(:comment)
      result = Comments::CreateService.call(author: @author, body: "reply", parent_id: parent.id)
      assert result.success?
      assert_equal parent, result.comment.parent
    end

    test "notifies the parent author on a reply" do
      thread = build_reply_thread
      parent_author = thread[:parent_author]

      assert_difference -> { parent_author.notifications.count }, 1 do
        perform_enqueued_jobs do
          Comments::CreateService.call(author: @author, body: "reply", parent: thread[:parent])
        end
      end
    end

    test "enqueues noticed event job on notifications queue" do
      thread = build_reply_thread

      perform_enqueued_jobs only: Comments::PostCreateJob do
        assert_enqueued_with(job: Noticed::EventJob, queue: "notifications") do
          Comments::CreateService.call(author: @author, body: "reply", parent: thread[:parent])
        end
      end
    end

    test "returns errors for a blank body" do
      result = Comments::CreateService.call(author: @author, body: "")
      assert_not result.success?
      assert_not_empty result.errors
    end

    test "returns error when parent_id does not exist" do
      result = Comments::CreateService.call(author: @author, body: "reply", parent_id: -1)

      assert result.failure?
      assert_includes result.errors, "Parent must exist"
      assert_not result.comment.persisted?
    end
  end
end
