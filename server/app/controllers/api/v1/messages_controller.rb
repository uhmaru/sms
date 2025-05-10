# typed: false

module Api
  module V1
    class MessagesController < ApiController
      def index
        messages = current_user.messages.order(created_at: :asc)

        render json: {
          success: true,
          messages: messages.map { |msg| MessageSerializer.new(msg, current_user.id.to_s).as_json }
        }, status: :ok
      rescue => e
        render_internal_error(e)
      end

      def create
        result = SendMessageService.new(
          user: current_user,
          recipient_number: message_params[:phone_number],
          body: message_params[:body],
          delivery_token: message_params[:delivery_token]
        ).call

        if result.success?
          render json: {
            success: true,
            message: MessageSerializer.new(T.must(result.data), current_user.id.to_s).as_json
          }, status: :created
        else
          render_error_messages(result.errors)
        end
      rescue => e
        render_internal_error(e)
      end

      def update_status
        message = current_user.messages.find_by(id: params[:id])
        return render_not_found("Message not found") unless message

        if message.update(update_status_params)
          render json: {
            success: true,
            message: MessageSerializer.new(message, current_user.id.to_s).as_json
          }, status: :ok
        else
          render_error_messages(message.errors.full_messages)
        end
      rescue => e
        render_internal_error(e)
      end

      private

      def message_params
        params.require(:message).permit(:body, :phone_number, :delivery_token)
      end

      def update_status_params
        params.require(:message).permit(:status)
      end

      def render_error_messages(errors)
        render json: {
          success: false,
          errors: errors
        }, status: :unprocessable_entity
      end

      def render_not_found(message)
        render json: {
          success: false,
          error: message
        }, status: :not_found
      end

      def render_internal_error(error)
        Rails.logger.error("[MessagesController] #{error.class}: #{error.message}")
        Rails.logger.error(error.backtrace.join("\n")) if error.backtrace

        render json: {
          success: false,
          error: "An unexpected error occurred. Please try again."
        }, status: :internal_server_error
      end
    end
  end
end
