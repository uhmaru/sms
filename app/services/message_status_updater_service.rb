# app/services/message_status_updater_service.rb
class MessageStatusUpdaterService
  def initialize(message, new_status)
    @message = message
    @new_status = new_status
  end

  def call
    @message.update!(status: @new_status)
  end
end
