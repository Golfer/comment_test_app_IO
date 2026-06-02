class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout :layout_for_request

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :touch_presence, unless: :devise_sign_out?

  protected

  def layout_for_request
    devise_controller? ? "authentication" : "application"
  end

  # Allow name through Devise's strong params on sign up / account update.
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # Lightweight presence heartbeat on every authenticated request.
  def touch_presence
    current_user&.touch_presence!
  end

  def devise_sign_out?
    devise_controller? && controller_name == "sessions" && action_name == "destroy"
  end
end
