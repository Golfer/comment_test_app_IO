class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  has_many :comments, dependent: :delete_all
  has_many :device_tokens, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"

  validates :name, presence: true, length: { maximum: 60 }

  PRESENCE_WINDOW = 2.minutes

  def online?
    last_seen_at.present? && last_seen_at >= PRESENCE_WINDOW.ago
  end

  def touch_presence!
    update_column(:last_seen_at, Time.current)
  end

  def clear_presence!
    update_column(:last_seen_at, nil)
  end

  def display_name
    name.presence || email.split("@").first
  end

  def initials
    display_name.split.map(&:first).first(2).join.upcase
  end

  def comments_count
    if has_attribute?(:comments_count)
      self[:comments_count].to_i
    else
      comments.count
    end
  end
end
