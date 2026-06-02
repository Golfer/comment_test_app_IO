module Comments
  class PostCreateJob < ApplicationJob
    queue_as :notifications

    discard_on ActiveRecord::RecordNotFound

    def perform(comment_id)
      comment = Comment.find(comment_id)
      Comments::BroadcastService.call(comment)
      Comments::NotifyService.call(comment)
    end
  end
end
