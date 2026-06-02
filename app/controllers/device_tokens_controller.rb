# Mobile push seam: a mobile client registers/unregisters its push token here.
class DeviceTokensController < ApplicationController
  before_action :authenticate_user!

  def create
    token = DeviceToken.find_or_initialize_by(token: params[:token])
    token.user = current_user
    token.platform = params[:platform].presence || :web

    if token.save
      render json: { id: token.id }, status: :created
    else
      render json: { errors: token.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def destroy
    current_user.device_tokens.where(id: params[:id]).destroy_all
    head :no_content
  end
end
