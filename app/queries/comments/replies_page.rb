module Comments
  # Immutable value object returned by RepliesQuery.
  RepliesPage = Data.define(:parent, :replies, :thread_reply_counts) do
    def empty?
      replies.empty?
    end

    def any_replies?
      !empty?
    end

    def reply_count
      replies.size
    end
  end
end
