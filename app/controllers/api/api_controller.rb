module Api
  class ApiController < ActionController::API
    include Devise::Controllers::Helpers

    before_action :authenticate_user!

    rescue_from JWT::ExpiredSignature, with: :handle_expired_token
    rescue_from JWT::DecodeError, with: :handle_invalid_token
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_unauthorized
    rescue_from Warden::NotAuthenticated, with: :handle_unauthorized
    rescue_from Mongoid::Errors::DocumentNotFound, with: :handle_not_found

    private

    def handle_unauthorized
      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    def handle_expired_token
      render json: { error: "Token has expired" }, status: :unauthorized
    end

    def handle_invalid_token
      render json: { error: "Invalid authentication token" }, status: :unauthorized
    end

    def handle_not_found
      render json: { error: "Resource not found" }, status: :not_found
    end
  end
end
