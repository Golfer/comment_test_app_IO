module Notifications
  # Single source for notification copy (DRY — notifier, mailer, push, views).
  module Presentation
    module_function

    I18N_SCOPE = "notifications.presentation".freeze
    DEFAULT_REASON = "default".freeze
    TITLE_KEYS = {
      "reply" => "title.reply",
      "thread_reply" => "title.thread_reply",
      "mention" => "title.mention",
      DEFAULT_REASON => "title.default"
    }.freeze
    MESSAGE_KEYS = {
      "reply" => "message.reply",
      "thread_reply" => "message.thread_reply",
      "mention" => "message.mention",
      DEFAULT_REASON => "message.default"
    }.freeze
    EMAIL_SUBJECT_KEYS = {
      "reply" => "email_subject.reply",
      "thread_reply" => "email_subject.thread_reply",
      "mention" => "email_subject.mention",
      DEFAULT_REASON => "email_subject.default"
    }.freeze

    def title(reason)
      translate_from(TITLE_KEYS, reason: reason)
    end

    def message(reason:, sender_name:, preview:)
      translate_from(
        MESSAGE_KEYS,
        reason: reason,
        sender_name: sender_name,
        preview: preview
      )
    end

    def email_subject(reason:, sender_name:)
      translate_from(EMAIL_SUBJECT_KEYS, reason: reason, sender_name: sender_name)
    end

    def translate_from(keys, reason:, **interpolations)
      key = keys.fetch(reason.to_s, keys.fetch(DEFAULT_REASON))
      I18n.t("#{I18N_SCOPE}.#{key}", **interpolations)
    end
  end
end
