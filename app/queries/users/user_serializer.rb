module Users
  module UserSerializer
    module_function

    def call(user)
      {
        id: user.id,
        name: user.display_name,
        email: user.email,
        initials: user.initials,
        online: user.online?,
        comments_count: user.comments_count
      }
    end
  end
end
