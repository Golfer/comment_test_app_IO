module CommentsTestHelpers
  module RequestHelpers
    def post_comment(body:, format: :json)
      post comments_path, params: { comment: { body: body } }, as: format
    end

    def post_reply(parent:, body:, format: :json)
      post comments_path,
           params: { comment: { body: body, parent_id: parent.id } },
           as: format
    end
  end

  module NotificationHelpers
    def perform_comment_notifications(comment)
      perform_enqueued_jobs do
        Comments::NotifyService.call(comment)
      end
    end

    def deliver_comment_notification(recipient:, sender:, comment:, reason: :reply)
      perform_enqueued_jobs do
        NewCommentNotifier.with(comment: comment, sender: sender, reason: reason).deliver([ recipient ])
      end
    end

    def build_reply_thread(with_nested_parent: false, body: "reply body")
      root_author = create(:user)
      replier = create(:user)
      root = create(:comment, user: root_author)

      if with_nested_parent
        parent_author = create(:user)
        parent = create(:comment, user: parent_author, parent: root)
      else
        parent_author = root_author
        parent = root
      end

      reply = create(:comment, user: replier, parent: parent, body: body)
      {
        root_author: root_author,
        parent_author: parent_author,
        replier: replier,
        root: root,
        parent: parent,
        reply: reply
      }
    end

    def build_reply_notification_subject(sender_name: "Alice", recipient_online: true, body: "Nice point")
      sender = create(:user, name: sender_name)
      recipient_last_seen_at = recipient_online ? Time.current : 1.hour.ago
      recipient = create(:user, last_seen_at: recipient_last_seen_at)
      parent = create(:comment, user: recipient)
      comment = create(:comment, user: sender, parent: parent, body: body)

      {
        sender: sender,
        recipient: recipient,
        parent: parent,
        comment: comment
      }
    end
  end
end
