namespace :fake do
  desc "Enqueue generation of N fake tree comments. Usage: rake 'fake:comments[1000000]' or with a chat id: rake 'fake:comments[1000000,12]'"
  task :comments, [ :count, :chat_id ] => :environment do |_t, args|
    count = (args[:count] || 1_000).to_i
    chat_id = args[:chat_id].presence
    FakeCommentsGenerationWorker.perform_async(count, chat_id)
    puts "Enqueued generation of #{count} fake comments#{chat_id ? " into chat #{chat_id}" : ""}."
    puts "Run 'rake fake:reindex' afterwards to populate Meilisearch."
  end

  desc "Re-index all comments into Meilisearch"
  task reindex: :environment do
    ReindexCommentsWorker.perform_async
    puts "Enqueued Meilisearch reindex of all comments."
  end
end
