# SimpleCov must start before any application code is loaded so it can track it.
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/app/channels/application_cable/connection.rb" # Warden glue, exercised via request specs
  add_filter "/app/javascript/"

  add_group "Services", "app/services"
  add_group "Queries", "app/queries"
  add_group "Workers", "app/workers"
  add_group "Notifiers", "app/notifiers"

  minimum_coverage line: 90
end

ENV["RAILS_ENV"] ||= "test"
# Keep search a no-op in tests; the Meilisearch server isn't available and
# indexing must not block or fail the suite.
ENV["MEILISEARCH_ENABLED"] = "false"

require_relative "../config/environment"
require "rails/test_help"
Dir[Rails.root.join("test/support/**/*.rb")].sort.each { |file| require file }

module ActiveSupport
  class TestCase
    # NOTE: not parallelizing — keeps a single SimpleCov result for accurate
    # coverage measurement.
    include FactoryBot::Syntax::Methods
    include ActiveJob::TestHelper
    include ActionCable::TestHelper
    include ActionMailer::TestHelper

    setup { Prosopite.scan if defined?(Prosopite) }
    teardown { Prosopite.finish if defined?(Prosopite) }

    # Lightweight singleton-method stub (minitest 6 dropped Mock/#stub).
    # Temporarily replaces `object.method_name` with `replacement` for the block.
    def with_stub(object, method_name, replacement)
      original = object.method(method_name)
      object.define_singleton_method(method_name) do |*args, **kwargs|
        replacement.call(*args, **kwargs)
      end
      yield
    ensure
      object.define_singleton_method(method_name) do |*args, **kwargs, &blk|
        original.call(*args, **kwargs, &blk)
      end
    end

    def with_env(values)
      previous = values.to_h { |key, _| [ key, ENV[key] ] }
      values.each { |key, value| ENV[key] = value }
      yield
    ensure
      previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    end
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include CommentsTestHelpers::RequestHelpers
end

class ActiveSupport::TestCase
  include CommentsTestHelpers::NotificationHelpers
end
