module Users
  # All users for the directory, ordered by name with comment counts.
  class DirectoryQuery < ApplicationQuery
    DEFAULT_PER = 100
    MAX_PER = 100

    def initialize(page: 1, per: DEFAULT_PER)
      @page = normalize_page(page)
      @per = normalize_per(per)
    end

    def call
      records = base_scope
                .offset((@page - 1) * @per)
                .limit(@per + 1)
                .to_a
      users = records.first(@per)
      next_page = records.size > @per ? @page + 1 : nil

      DirectoryPage.new(
        users: users,
        page: @page,
        per: @per,
        total: User.count,
        next_page: next_page
      )
    end

    private

    def base_scope
      User.left_joins(:comments)
          .group("users.id")
          .order(:name)
          .select("users.*, COUNT(comments.id) AS comments_count")
    end

    def normalize_page(value)
      parsed = value.to_i
      parsed.positive? ? parsed : 1
    end

    def normalize_per(value)
      parsed = value.to_i
      parsed = DEFAULT_PER unless parsed.positive?
      [ parsed, MAX_PER ].min
    end
  end
end
