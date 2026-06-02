module Comments
  SearchResult = Data.define(:query, :page, :per, :total, :hits, :search_comments, :next_page) do
    def empty?
      total.zero?
    end

    def any_hits?
      hits.any?
    end
  end
end
