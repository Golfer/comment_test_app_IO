class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    page = Users::DirectoryQuery.call(page: params[:page], per: params[:per])
    @users = page.users
    @next_page = page.next_page

    respond_to do |format|
      format.html { render_users_index_html }
      format.json { render json: Users::DirectorySerializer.call(@users) }
    end
  end

  def show
    page = Users::ProfileQuery.call(user: User.find(params[:id]))
    @user = page.user
    @comments = page.comments

    respond_to do |format|
      format.html
      format.json { render json: Users::ProfilePageSerializer.call(page) }
    end
  end

  private

  def render_users_index_html
    return unless turbo_frame_request?

    requested_frame_id = request.headers["Turbo-Frame"].to_s
    return head :bad_request if requested_frame_id.blank?

    render partial: "users/page_frame",
           locals: {
             frame_id: requested_frame_id,
             users: @users,
             next_page: @next_page
           }
  end
end
