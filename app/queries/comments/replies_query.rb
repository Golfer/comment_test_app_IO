module Comments
  # Full thread under a root comment with batch reply counts.
  class RepliesQuery < ApplicationQuery
    def initialize(parent_id:)
      @parent_id = parent_id
    end

    def call
      parent = Comment.find(@parent_id)
      replies = parent.descendants.includes(:user).order(:ancestry_depth, :created_at)

      RepliesPage.new(
        parent: parent,
        replies: replies,
        thread_reply_counts: ThreadCountsQuery.call(replies, within: true)
      )
    end
  end
end
