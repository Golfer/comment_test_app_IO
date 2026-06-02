module Comments
  # Immutable value object returned by IndexQuery (HTML + JSON index).
  IndexPage = Data.define(
    :search_result,
    :roots,
    :thread_reply_counts,
    :open_thread_id,
    :highlight_comment_id,
    :next_page
  ) do
    def search?
      !search_result.nil?
    end

    def feed?
      search_result.nil?
    end

    def search_comments
      search_result&.search_comments || {}
    end
  end
end
