namespace :comments do
  desc "Strip HTML/markdown images from existing comment bodies"
  task normalize_bodies: :environment do
    updated = 0

    Comment.find_each do |comment|
      raw = comment.read_attribute(:body)
      normalized = Comment.normalize_body(raw).presence || "…"
      next if normalized == raw

      comment.update_column(:body, normalized)
      updated += 1
    end

    puts "Normalized #{updated} comment bodies."
  end
end
