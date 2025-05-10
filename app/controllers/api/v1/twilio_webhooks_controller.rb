# frozen_string_literal: true

module Api
  module V1
    class TwilioWebhooksController < ActionController::API
      def create
        unless valid_twilio_signature?
          return head :unauthorized
        end

        sid = permitted_params["MessageSid"]
        status = permitted_params["MessageStatus"]

        message = Message.find_by(twilio_sid: sid)
        message.update(status: status) if message

        head :ok
      end

      private


      def valid_twilio_signature?
        return true unless Rails.env.production?

        twilio_signature = request.headers["X-Twilio-Signature"]
        return false if twilio_signature.nil?

        url = request.original_url
        validator = Twilio::Security::RequestValidator.new(ENV.fetch("TWILIO_AUTH_TOKEN"))
        validator.validate(url, params.to_unsafe_h, twilio_signature)
      end

      def permitted_params
        params.permit(:To, :From, :Body, :MessageSid, :AccountSid, :SmsStatus, :NumMedia, :MessageStatus)
      end
    end
  end
end
