class CommentsController < ApplicationController
  before_action :authenticate_user!

  def index
    page = Comments::IndexQuery.call(params)
    assign_index_page(page)

    respond_to do |format|
      format.html { render_index_html(page) }
      format.json { render json: Comments::IndexPageSerializer.call(page, params) }
    end
  end

  def replies
    assign_replies_page(Comments::RepliesQuery.call(parent_id: params[:id]))
    render layout: false
  end

  def create
    result = Comments::CreateService.call(
      author: current_user,
      body: comment_params[:body],
      parent_id: comment_params[:parent_id]
    )

    result.success? ? respond_create_success(result) : respond_create_failure(result)
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def assign_index_page(page)
    @search_result = page.search_result
    @search_comments = page.search_comments
    @roots = page.roots
    @thread_reply_counts = page.thread_reply_counts
    @open_thread_id = page.open_thread_id
    @highlight_comment_id = page.highlight_comment_id
    @next_page = page.next_page
  end

  def render_index_html(page)
    return unless turbo_frame_request?

    requested_frame_id = request.headers["Turbo-Frame"].to_s
    return head :bad_request if requested_frame_id.blank?

    if page.feed?
      render partial: "comments/feed_page_frame",
             locals: {
               frame_id: requested_frame_id,
               roots: @roots,
               thread_reply_counts: @thread_reply_counts,
               open_thread_id: @open_thread_id,
               next_page: @next_page
             }
    elsif page.search?
      render partial: "comments/search_page_frame",
             locals: {
               frame_id: requested_frame_id,
               search_result: @search_result,
               search_comments: @search_comments
             }
    end
  end

  def assign_replies_page(page)
    @parent = page.parent
    @replies = page.replies
    @thread_reply_counts = page.thread_reply_counts
  end

  def respond_create_success(result)
    respond_to do |format|
      format.turbo_stream { head :ok }
      format.json { render json: result.comment.as_json_node, status: :created }
      format.html { redirect_to comments_path, notice: "Comment posted." }
    end
  end

  def respond_create_failure(result)
    respond_to do |format|
      format.json { render json: { errors: result.errors }, status: :unprocessable_entity }
      format.html { redirect_to comments_path, alert: result.errors.join(", ") }
    end
  end
end
