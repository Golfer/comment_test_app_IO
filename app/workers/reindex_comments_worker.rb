# Rebuilds the Meilisearch index for comments in batches. Run this after a
# bulk import (FakeCommentsGenerationWorker), since `insert_all` skips the
# per-record indexing callbacks.
class ReindexCommentsWorker
  include Sidekiq::Job

  sidekiq_options queue: :generation, retry: 1

  def perform
    # meilisearch-rails imports in batches and replaces the index atomically.
    Comment.reindex!
    Rails.logger.info("[ReindexCommentsWorker] reindexed #{Comment.count} comments")
  end
end
