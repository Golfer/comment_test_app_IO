class Comment < ApplicationRecord
  include MeiliSearch::Rails

  has_ancestry cache_depth: true, depth_cache_column: :ancestry_depth

  belongs_to :user

  validates :body, presence: true, length: { maximum: 10_000 }

  before_validation :normalize_body_field

  scope :recent_roots, -> { roots.order(created_at: :desc) }

  PREVIEW_LENGTH = 80
  FALLBACK_BODY = "…".freeze
  MARKDOWN_IMAGE_PATTERN = /!\[[^\]]*\]\([^)]+\)/.freeze
  WHITESPACE_PATTERN = /\s+/.freeze

  meilisearch enqueue: true, if: :searchable? do
    attribute :body
    attribute :author_name do
      user.display_name
    end
    attribute :created_at_unix do
      created_at.to_i
    end
    attribute :depth do
      ancestry_depth
    end

    searchable_attributes [ :body, :author_name ]
    filterable_attributes [ :depth ]
    sortable_attributes [ :created_at_unix ]
  end

  def searchable?
    body.present?
  end

  def body_preview
    plain_body.truncate(PREVIEW_LENGTH)
  end

  def plain_body
    self.class.normalize_body(body)
  end

  def deep_link_path
    self.class.deep_link_path(self)
  end

  def as_json_node(include_children_count: true, children_count: nil)
    {
      id: id,
      body: plain_body,
      parent_id: parent_id,
      depth: ancestry_depth,
      created_at: created_at.iso8601,
      children_count: resolved_children_count(include_children_count, children_count),
      user: serialized_user
    }.compact
  end

  class << self
    def normalize_body(text)
      plain = ActionController::Base.helpers.strip_tags(text.to_s)
      plain = plain.gsub(MARKDOWN_IMAGE_PATTERN, "")
      plain.gsub(WHITESPACE_PATTERN, " ").strip.presence
    end

    def deep_link_path(comment)
      Rails.application.routes.url_helpers.comments_path(
        thread: comment.root_id,
        highlight: comment.id
      )
    end
  end

  private

  def resolved_children_count(include_children_count, children_count)
    return nil unless include_children_count
    return children_count unless children_count.nil?

    self.class.where(ancestry: child_ancestry).count
  end

  def serialized_user
    {
      id: user_id,
      name: user.display_name,
      initials: user.initials
    }
  end

  def normalize_body_field
    return if body.blank?

    self.body = self.class.normalize_body(body) || FALLBACK_BODY
  end
end
