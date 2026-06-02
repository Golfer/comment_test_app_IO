require "faker"

class FakeCommentsGenerationWorker
  include Sidekiq::Job

  sidekiq_options queue: :generation, retry: 1

  BATCH = 5_000
  MAX_PER_RUN = 100_000
  POOL_CAP = 20_000
  MAX_DEPTH = 8
  REPLY_PROBABILITY = 0.7
  ROOT_SEED_FRACTION = 0.1

  def perform(total, user_ids = nil)
    total = total.to_i
    return if total <= 0

    user_ids ||= ensure_user_pool
    pool = seed_parent_pool

    run_limit = [ total, MAX_PER_RUN ].min
    produced = 0

    if pool.empty?
      seed = [ [ (run_limit * ROOT_SEED_FRACTION).ceil, 1 ].max, run_limit ].min
      produced += insert_chunk(seed, user_ids, pool, roots_only: true)
    end

    while produced < run_limit
      slice = [ BATCH, run_limit - produced ].min
      produced += insert_chunk(slice, user_ids, pool, roots_only: false)
    end

    remaining = total - produced
    if remaining.positive?
      self.class.perform_async(remaining, user_ids)
    else
      Rails.logger.info("[FakeCommentsGenerationWorker] done; total=#{Comment.count}")
    end
  end

  private

  def ensure_user_pool(target = 25)
    ids = User.limit(target).pluck(:id)
    ids << create_fake_user.id while ids.size < target
    ids
  end

  def create_fake_user
    User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.unique.email,
      password: SecureRandom.hex(12)
    )
  end

  def seed_parent_pool
    Comment.order(id: :desc).limit(POOL_CAP)
           .pluck(:id, :ancestry, :ancestry_depth)
           .map { |id, ancestry, depth| { id: id, ancestry: ancestry, depth: depth } }
  end

  def insert_chunk(count, user_ids, pool, roots_only:)
    rows = build_rows(count, user_ids, pool, roots_only: roots_only)
    inserted = Comment.insert_all!(rows, returning: %w[id ancestry ancestry_depth])
    refill_pool(pool, inserted)
    count
  end

  def build_rows(count, user_ids, pool, roots_only:)
    now = Time.current
    Array.new(count) do
      parent = roots_only ? nil : pick_parent(pool)
      ancestry = parent && child_ancestry(parent)
      depth = parent ? parent[:depth] + 1 : 0

      {
        user_id: user_ids.sample,
        body: Faker::Lorem.paragraph(sentence_count: rand(1..4)),
        ancestry: ancestry,
        ancestry_depth: depth,
        created_at: now,
        updated_at: now
      }
    end
  end

  def pick_parent(pool)
    return nil if pool.empty?
    return nil if rand > REPLY_PROBABILITY

    candidate = pool.sample
    candidate[:depth] < MAX_DEPTH ? candidate : nil
  end

  def child_ancestry(parent)
    parent[:ancestry].present? ? "#{parent[:ancestry]}/#{parent[:id]}" : parent[:id].to_s
  end

  def refill_pool(pool, inserted)
    inserted.rows.each do |id, ancestry, depth|
      pool << { id: id, ancestry: ancestry, depth: depth }
    end
    pool.shift(pool.size - POOL_CAP) if pool.size > POOL_CAP
  end
end
