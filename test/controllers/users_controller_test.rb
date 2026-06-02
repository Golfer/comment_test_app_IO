require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    sign_in @user
  end

  test "index lists users as json" do
    create(:user)
    get users_path, as: :json
    assert_response :success
    assert_equal 2, response.parsed_body.size
  end

  test "index renders the people page as html" do
    create(:user, name: "Bob Smith")
    get users_path
    assert_response :success
    assert_match "People", response.body
    assert_match "Bob Smith", response.body
  end

  test "show renders a user's comments" do
    author = create(:user, name: "Bob Smith")
    create(:comment, user: author, body: "hello from bob")
    create(:comment, user: author, body: "another one")

    get user_path(author)
    assert_response :success
    assert_match "Bob Smith", response.body
    assert_match "hello from bob", response.body
    assert_match "another one", response.body
    assert_match "Open in thread", response.body
  end

  test "show returns comments as json" do
    author = create(:user)
    comment = create(:comment, user: author, body: "json comment")

    get user_path(author), as: :json
    assert_response :success
    assert_equal author.id, response.parsed_body["user"]["id"]
    assert_equal 1, response.parsed_body["comments"].size
    assert_equal comment.id, response.parsed_body["comments"].first["id"]
  end
end
