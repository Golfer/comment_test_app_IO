module Users
  class ProfileQuery < ApplicationQuery
    def initialize(user:)
      @user = user
    end

    def call
      ProfilePage.new(
        user: @user,
        comments: Comments::ByUserQuery.call(user: @user)
      )
    end
  end
end
