module Notifications
  # Batch-loads comment/sender records and injects params once per notification.
  module EventParamsPreloader
    SNAPSHOT_KEYS = %w[sender_name comment_preview comment_id root_comment_id url reason].freeze

    module_function

    def call(notifications)
      return notifications if notifications.empty?

      events = notifications.filter_map(&:event)
      return notifications if events.empty?

      raw_by_event_id = bulk_raw_params(events)
      raw_by_notification = build_raw_map(notifications, raw_by_event_id)
      legacy_raw = raw_by_notification.values.reject { |raw| snapshot?(raw) }
      records = preload_records(legacy_raw)

      notifications.each do |notification|
        event = notification.event
        next if event.nil?

        raw = raw_by_notification.fetch(notification)
        params = params_for(raw, records)
        inject!(event, params)
      end

      notifications
    end

    def build_raw_map(notifications, raw_by_event_id)
      notifications.each_with_object({}) do |notification, hash|
        event_id = notification.event&.id
        hash[notification] = event_id ? raw_by_event_id.fetch(event_id, {}) : {}
      end
    end

    def preload_records(legacy_raw)
      comment_ids = legacy_raw.filter_map { |raw| comment_id_from(raw) }.uniq
      sender_ids = legacy_raw.filter_map { |raw| sender_id_from(raw) }.uniq

      {
        comments: Comment.where(id: comment_ids).index_by(&:id),
        users: User.where(id: sender_ids).index_by(&:id)
      }
    end

    def params_for(raw, records)
      return raw.with_indifferent_access if snapshot?(raw)

      comment = records[:comments][comment_id_from(raw)]
      sender = records[:users][sender_id_from(raw)]
      return raw.with_indifferent_access if comment.nil? || sender.nil?

      build_params(comment, sender, raw)
    end

    def bulk_raw_params(events)
      ids = events.map(&:id)
      return {} if ids.empty?

      sql = Noticed::Event.sanitize_sql_array([ "SELECT id, params FROM noticed_events WHERE id IN (?)", ids ])
      Noticed::Event.connection.select_all(sql).each_with_object({}) do |row, hash|
        params = row["params"]
        params = JSON.parse(params) if params.is_a?(String)
        hash[row["id"]] = params.is_a?(Hash) ? params : {}
      end
    end

    def snapshot?(raw)
      SNAPSHOT_KEYS.all? { |key| raw[key].present? }
    end

    def build_params(comment, sender, raw)
      {
        comment: comment,
        sender: sender,
        reason: raw["reason"].to_s,
        sender_name: sender.display_name,
        comment_preview: comment.body_preview,
        comment_id: comment.id,
        root_comment_id: comment.root_id,
        url: Comment.deep_link_path(comment)
      }.with_indifferent_access
    end

    def inject!(event, params)
      event.define_singleton_method(:params) { params }
    end

    def comment_id_from(raw)
      model_id(raw["comment_id"] || raw["comment"])
    end

    def sender_id_from(raw)
      model_id(raw["sender_id"] || raw["sender"])
    end

    def model_id(value)
      return value if value.is_a?(Integer)
      return value.id if value.is_a?(ActiveRecord::Base)

      gid = value.is_a?(Hash) ? value["_aj_globalid"] : value
      return if gid.blank?

      GlobalID.parse(gid)&.model_id&.to_i
    end
  end
end
