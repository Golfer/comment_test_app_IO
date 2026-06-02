module Comments
  # Recent comments authored by a single user.
  class ByUserQuery < ApplicationQuery
    DEFAULT_LIMIT = 100

    def initialize(user:, limit: DEFAULT_LIMIT)
      @user = user
      @limit = limit
    end

    def call
      Comment.where(user: @user)
             .includes(:user)
             .order(created_at: :desc)
             .limit(@limit)
    end
  end
end
