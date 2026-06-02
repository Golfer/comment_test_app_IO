require "sidekiq/web"
require "digest"

sidekiq_dashboard_username = ENV["SIDEKIQ_DASHBOARD_USERNAME"].to_s
sidekiq_dashboard_password = ENV["SIDEKIQ_DASHBOARD_PASSWORD"].to_s

if sidekiq_dashboard_username.present? && sidekiq_dashboard_password.present?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username_match = ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(username.to_s),
      Digest::SHA256.hexdigest(sidekiq_dashboard_username)
    )
    password_match = ActiveSupport::SecurityUtils.secure_compare(
      Digest::SHA256.hexdigest(password.to_s),
      Digest::SHA256.hexdigest(sidekiq_dashboard_password)
    )
    username_match && password_match
  end
end

Rails.application.routes.draw do
  # Authentication
  devise_for :users, controllers: { sessions: "users/sessions" }
  get "up" => "rails/health#show", as: :rails_health_check

  # Core app
  resources :comments, only: [ :index, :create ] do
    get :replies, on: :member
  end
  resources :users, only: [ :index, :show ]
  resources :notifications, only: [ :index, :show ] do
    post :read, on: :member
    post :read_all, on: :collection
  end
  resources :device_tokens, only: [ :create, :destroy ]

  # Realtime/admin
  mount ActionCable.server => "/cable"
  mount Sidekiq::Web => "/sidekiq"

  # Root routing
  authenticated :user do
    root "comments#index", as: :authenticated_root
  end
  root "home#index"
end
