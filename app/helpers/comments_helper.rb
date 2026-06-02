module CommentsHelper
  # Plain text only — never render stored HTML in comment bodies.
  def comment_body(comment)
    comment.plain_body
  end

  # Search snippets may include <mark> tags from SearchQuery#highlight_text.
  def search_snippet(html)
    sanitize(html.to_s, tags: %w[mark], attributes: %w[class])
  end
end
