class DeviceToken < ApplicationRecord
  # Seam for future mobile push (FCM/APNs). Tokens registered by a mobile client
  # are stored here so the push delivery method can target a user's devices.
  PLATFORMS = { ios: 0, android: 1, web: 2 }.freeze
  enum :platform, PLATFORMS

  belongs_to :user

  validates :token, presence: true, uniqueness: true
end
