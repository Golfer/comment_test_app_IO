require "test_helper"

module Comments
  class SearchQueryTest < ActiveSupport::TestCase
    test "returns an empty result for a blank query" do
      result = Comments::SearchQuery.call(query: "")
      assert_equal 0, result.total
      assert_empty result.hits
    end

    test "searches the database when meilisearch is disabled" do
      user = create(:user, name: "Alice")
      comment = create(:comment, user: user, body: "hello world")

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "hello")
        assert_equal 1, result.total
        assert_equal comment.id, result.hits.first.id
        assert_match "hello", result.hits.first.highlighted_body
      end
    end

    test "strips html from highlighted body" do
      create(:comment, body: '<img src="/static/media/photo.avif"> secret needle')

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "needle")
        hit = result.hits.first
        assert_no_match %r{<img|static/media}, hit.highlighted_body
        assert_match "needle", hit.highlighted_body
      end
    end

    test "finds substrings anywhere in body or author name via ilike" do
      create(:comment, body: "alpha\nbeta needle gamma")
      create(:comment, user: create(:user, name: "Jonathan"), body: "unrelated")

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        middle_of_line = Comments::SearchQuery.call(query: "needle")
        assert_equal 1, middle_of_line.total

        middle_of_word = Comments::SearchQuery.call(query: "eed")
        assert_equal 1, middle_of_word.total

        author_substring = Comments::SearchQuery.call(query: "nathan")
        assert_equal 1, author_substring.total
      end
    end

    test "requires every search term to match somewhere" do
      create(:comment, body: "hello world")
      create(:comment, body: "hello only")

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "hello world")
        assert_equal 1, result.total
      end
    end

    test "loads comment records when include_comments is true" do
      comment = create(:comment, body: "hello world")

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "hello", include_comments: true)
        assert_equal comment, result.search_comments[comment.id]
        assert_equal comment.root_id, result.hits.first.root_id
      end
    end

    test "returns next_page when more search results exist" do
      21.times { create(:comment, body: "hello world") }

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "hello")
        assert_equal 2, result.next_page
      end
    end

    test "returns nil next_page on final search page" do
      21.times { create(:comment, body: "hello world") }

      with_stub(MeiliSearch::Rails, :active?, -> { false }) do
        result = Comments::SearchQuery.call(query: "hello", page: 2)
        assert_nil result.next_page
      end
    end

    test "formats hits when search is enabled" do
      raw = {
        "hits" => [ {
          "id" => 7,
          "author_name" => "Alice", "body" => "needle in haystack",
          "_formatted" => { "body" => "<em>needle</em> in haystack" }
        } ],
        "totalHits" => 1
      }

      captured = {}
      raw_search = lambda do |query, options|
        captured[:query] = query
        captured[:options] = options
        raw
      end

      with_stub(MeiliSearch::Rails, :active?, -> { true }) do
        with_env("MEILISEARCH_SEARCH_ENABLED" => "true") do
          with_stub(Comment, :ms_raw_search, raw_search) do
            result = Comments::SearchQuery.call(query: "needle")
            assert_equal 1, result.total
            hit = result.hits.first
            assert_equal 7, hit.id
            assert_equal "needle in haystack", hit.highlighted_body
          end
        end
      end

      assert_equal "needle", captured[:query]
      assert_nil captured[:options][:filter]
    end
  end
end
