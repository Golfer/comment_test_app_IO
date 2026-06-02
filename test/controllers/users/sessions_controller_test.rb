require "test_helper"

module Users
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    include ActionCable::TestHelper

    test "sign out clears online presence" do
      user = create(:user, last_seen_at: Time.current)
      sign_in user

      delete destroy_user_session_path

      assert_response :redirect
      assert_nil user.reload.last_seen_at
      assert_not user.online?
    end

    test "sign out broadcasts offline to presence stream" do
      user = create(:user, last_seen_at: Time.current)
      sign_in user

      assert_broadcasts(Users::PresenceCable::STREAM, 1) do
        delete destroy_user_session_path
      end
    end

    test "session expires after one hour of inactivity" do
      user = create(:user)
      sign_in user

      get comments_path
      assert_response :success

      travel 61.minutes do
        get comments_path
        # Devise 5 timeout on GET redirects to the attempted path first, then the
        # protected action sends the guest to sign in.
        assert_redirected_to comments_path
        assert flash[:timedout]

        follow_redirect!
        assert_redirected_to new_user_session_path
        assert_equal I18n.t("devise.failure.timeout"), flash[:alert]
      end
    end
  end
end
