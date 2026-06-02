module Comments
  # Notifies parent author, root author (thread activity), and @mentioned users.
  class NotifyService < ApplicationService
    MENTION_PATTERN = /@(\w+)/

    def initialize(comment)
      @comment = comment
      @author = comment.user
    end

    def call
      build_recipients.each do |user, reason|
        NewCommentNotifier.with(notifier_params(reason)).deliver(user)
      end
    end

    def notifier_params(reason)
      {
        comment: @comment,
        sender: @author,
        reason: reason.to_s,
        sender_name: @author.display_name,
        comment_preview: @comment.body_preview,
        comment_id: @comment.id,
        root_comment_id: @comment.root_id,
        url: Comment.deep_link_path(@comment)
      }
    end

    private

    def build_recipients
      recipients = mention_recipients
      assign_reply_recipient!(recipients)
      assign_thread_reply_recipient!(recipients)

      User.where(id: recipients.keys).index_with { |user| recipients[user.id] }
    end

    def mention_recipients
      mentioned_user_ids.each_with_object({}) do |user_id, recipients|
        next if user_id == @author.id

        recipients[user_id] = :mention
      end
    end

    def assign_reply_recipient!(recipients)
      parent_user_id = @comment.parent&.user_id
      return if parent_user_id.blank? || parent_user_id == @author.id

      recipients[parent_user_id] = :reply
    end

    def assign_thread_reply_recipient!(recipients)
      return if @comment.parent_id.blank?

      root_user_id = @comment.root.user_id
      return if root_user_id == @author.id || recipients.key?(root_user_id)

      recipients[root_user_id] = :thread_reply
    end

    def mentioned_user_ids
      tokens = @comment.body.to_s.scan(MENTION_PATTERN).flatten.map(&:downcase)
      return [] if tokens.empty?

      User.where("LOWER(SPLIT_PART(name, ' ', 1)) IN (?)", tokens).pluck(:id)
    end
  end
end
