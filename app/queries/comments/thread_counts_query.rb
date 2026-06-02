module Comments
  # Batch reply counts for comment trees (feed roots or replies within a thread).
  class ThreadCountsQuery < ApplicationQuery
    def initialize(records, within: false)
      @records = records
      @within = within
    end

    def call
      return {} if @records.blank?

      @within ? counts_within : counts_for_roots
    end

    def self.direct_children(records)
      return {} if records.blank?

      paths = records.map(&:child_ancestry)
      Comment.where(ancestry: paths).group(:ancestry).count
    end

    private

    def counts_within
      list = @records.to_a
      list.to_h do |record|
        prefix = record.child_ancestry
        count = list.count do |other|
          other.id != record.id &&
            (other.ancestry == prefix || other.ancestry&.start_with?("#{prefix}/"))
        end
        [ record.id, count ]
      end
    end

    def counts_for_roots
      roots = @records.to_a
      root_ids = roots.map(&:id)
      counts = root_ids.index_with { 0 }

      root_sql = "split_part(comments.ancestry, '/', 1)::bigint"
      grouped_counts = Comment.where.not(ancestry: nil)
                              .where("#{root_sql} IN (?)", root_ids)
                              .group(Arel.sql(root_sql))
                              .count
      grouped_counts.each do |root_id, count|
        counts[root_id.to_i] = count
      end
      counts
    end
  end
end
