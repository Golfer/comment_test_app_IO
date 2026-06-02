require "test_helper"

module Users
  class DirectoryQueryTest < ActiveSupport::TestCase
    test "returns all users ordered by name with comment counts" do
      viewer = create(:user, name: "Zed")
      bob = create(:user, name: "Bob")
      ann = create(:user, name: "Ann")
      create(:comment, user: bob)
      create(:comment, user: bob)
      create(:comment, user: ann)

      page = DirectoryQuery.call
      users = page.users
      assert_equal %w[Ann Bob Zed], users.map(&:name)
      assert_equal 1, users.find { |user| user.id == ann.id }.comments_count
      assert_equal 2, users.find { |user| user.id == bob.id }.comments_count
      assert_equal 0, users.find { |user| user.id == viewer.id }.comments_count
      assert_nil page.next_page
    end

    test "returns only first 100 users on initial page" do
      101.times { |idx| create(:user, name: format("User %03d", idx)) }

      page = DirectoryQuery.call

      assert_equal 100, page.users.size
      assert_equal 2, page.next_page
    end

    test "returns next users page" do
      101.times { |idx| create(:user, name: format("User %03d", idx)) }

      page = DirectoryQuery.call(page: 2)

      assert_equal 1, page.users.size
      assert_nil page.next_page
    end
  end
end
