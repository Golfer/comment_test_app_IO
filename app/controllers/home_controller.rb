class HomeController < ApplicationController
  # Public landing page. Signed-in users are routed straight to chats#index by
  # the `authenticated :user` root in config/routes.rb.
  def index
  end
end
