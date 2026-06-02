module Users
  module ProfilePageSerializer
    module_function

    def call(page)
      {
        user: UserSerializer.call(page.user),
        comments: page.comments.map { |comment| Comments::ProfileCommentSerializer.call(comment) }
      }
    end
  end
end
