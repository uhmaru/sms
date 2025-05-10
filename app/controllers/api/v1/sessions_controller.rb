class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  respond_to :json
  wrap_parameters false

  private

  def respond_with(resource, _opts = {})
    if resource.present?
      token = Warden::JWTAuth::UserEncoder.new.call(current_user, :user, nil).first

      render json: {
        message: "Logged in successfully.",
        user: {
          id: current_user.id.to_s,
          email: current_user.email
        },
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid email or password." }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if current_user
      render json: { message: "Logged out successfully." }, status: :ok
    else
      render json: { message: "User already logged out or token invalid." }, status: :unauthorized
    end
  end

  def auth_options
    { scope: :user, recall: "#{controller_path}#new" }
  end
end
