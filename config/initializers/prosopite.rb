return unless defined?(Prosopite)

# Prosopite flags N+1 queries.
# https://github.com/charkost/prosopite
module ProsopiteInitializer
  module_function

  def configure!
    Prosopite.rails_logger = true
    Prosopite.raise = true if Rails.env.test?
    install_controller_hook if Rails.env.development?
  end

  def install_controller_hook
    ActiveSupport.on_load(:action_controller_base) do
      around_action do |_, action|
        Prosopite.scan
        action.call
      ensure
        Prosopite.finish
      end
    end
  end
end

ProsopiteInitializer.configure!
