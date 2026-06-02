module Comments
  # Turbo Stream + Action Cable updates when a comment is created.
  class BroadcastService < ApplicationService
    include ActionView::RecordIdentifier

    STREAM = "comments"

    def initialize(comment)
      @comment = comment
    end

    def call
      @comment = Comment.includes(:user).find(@comment.id)

      Turbo::StreamsChannel.broadcast_remove_to(STREAM, target: "comments_empty")

      if @comment.parent_id?
        broadcast_reply
      else
        broadcast_root
      end

      ActionCable.server.broadcast(STREAM, {
        type: "comment",
        comment: @comment.as_json_node(children_count: 0)
      })
    end

    private

    def broadcast_root
      Turbo::StreamsChannel.broadcast_prepend_to(
        STREAM,
        target: "comments_list",
        partial: "comments/comment",
        locals: root_locals
      )
    end

    def broadcast_reply
      root = @comment.root
      parent = @comment.parent
      reply_counts = reply_counts_for(root, parent)

      Turbo::StreamsChannel.broadcast_append_to(
        STREAM,
        target: dom_id(root, :replies_list),
        partial: "comments/comment",
        locals: reply_locals(root)
      )

      broadcast_thread_summary(root, count: reply_counts.fetch(root.id), compact: false)
      return if parent.id == root.id

      broadcast_thread_summary(parent, count: reply_counts.fetch(parent.id), compact: true)
    end

    def reply_counts_for(root, parent)
      counts = ThreadCountsQuery.call([ root ])
      counts[parent.id] = parent.descendants.count if parent.id != root.id
      counts
    end

    def broadcast_thread_summary(comment, count:, thread_open: false, compact: false)
      Turbo::StreamsChannel.broadcast_update_to(
        STREAM,
        target: dom_id(comment, :thread_badge),
        partial: "comments/thread_badge",
        locals: { comment: comment, thread_reply_count: count, compact: compact }
      )
      return if compact || !comment.root?

      Turbo::StreamsChannel.broadcast_replace_to(
        STREAM,
        target: dom_id(comment, :thread_meta),
        partial: "comments/thread_meta",
        locals: { comment: comment, thread_reply_count: count, thread_open: thread_open }
      )
    end

    def reply_locals(root)
      {
        comment: @comment,
        thread_reply_count: 0,
        depth: @comment.ancestry_depth - root.ancestry_depth,
        thread_expanded: true
      }
    end

    def root_locals
      {
        comment: @comment,
        thread_reply_count: 0,
        depth: 0,
        thread_expanded: false,
        thread_open: false
      }
    end
  end
end
