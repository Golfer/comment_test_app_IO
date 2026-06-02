Rails.application.config.to_prepare do
  next unless defined?(Noticed::EventJob)

  Noticed::EventJob.queue_as :notifications
end
