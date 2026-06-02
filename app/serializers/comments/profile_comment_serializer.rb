module Comments
  module ProfileCommentSerializer
    module_function

    def call(comment)
      {
        id: comment.id,
        body: comment.plain_body,
        created_at: comment.created_at.iso8601,
        root: comment.root?,
        url: comment.deep_link_path
      }
    end
  end
end
