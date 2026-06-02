module Users
  module DirectorySerializer
    module_function

    def call(users)
      users.map { |user| UserSerializer.call(user) }
    end
  end
end
