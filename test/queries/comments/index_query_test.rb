require "test_helper"

module Comments
  class IndexQueryTest < ActiveSupport::TestCase
    test "returns feed roots newest first" do
      older = create(:comment, body: "older", created_at: 2.days.ago)
      newer = create(:comment, body: "newer", created_at: 1.hour.ago)

      page = IndexQuery.call({})

      assert_equal [ newer.id, older.id ], page.roots.map(&:id)
    end

    test "returns feed data when no search query" do
      root = create(:comment, body: "root")
      create(:comment, parent: root)

      page = IndexQuery.call({})

      assert_equal [ root.id ], page.roots.map(&:id)
      assert_equal 1, page.thread_reply_counts.fetch(root.id)
      assert_equal 0, page.open_thread_id
      assert_nil page.search_result
      assert_nil page.next_page
    end

    test "returns only first 100 roots on initial page" do
      roots = Array.new(101) { create(:comment) }

      page = IndexQuery.call({})

      assert_equal 100, page.roots.size
      assert_equal roots.last.id, page.roots.first.id
      assert_equal 2, page.next_page
    end

    test "returns next feed page when page is provided" do
      roots = Array.new(101) { create(:comment) }

      page = IndexQuery.call({ page: 2 })

      assert_equal 1, page.roots.size
      assert_equal roots.first.id, page.roots.first.id
      assert_nil page.next_page
    end

    test "returns search data when query is present" do
      create(:comment, body: "hello world")

      page = IndexQuery.call({ q: "hello" })

      assert_not_nil page.search_result
      assert_operator page.search_result.total, :>=, 1
      assert_equal 0, page.open_thread_id
    end

    test "includes requested thread root even when it is older than first page" do
      old_root = create(:comment, created_at: 3.days.ago)
      100.times { create(:comment, created_at: 1.day.ago) }

      page = IndexQuery.call({ thread: old_root.id })

      assert_equal old_root.id, page.roots.first.id
      assert_equal old_root.id, page.open_thread_id
    end

    test "serializer returns tree for feed" do
      create(:comment)

      page = IndexQuery.call({})
      json = IndexPageSerializer.call(page, {})

      assert_equal 1, json[:total]
    end
  end
end
