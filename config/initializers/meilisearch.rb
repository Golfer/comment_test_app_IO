MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_URL", "http://localhost:7700"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY", "masterKey"),
  # Index documents asynchronously through Sidekiq so writes stay fast and
  # bulk imports don't block on the search engine.
  active: ENV.fetch("MEILISEARCH_ENABLED", "true") == "true"
}
