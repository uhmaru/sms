# typed: strict
# frozen_string_literal: true

class SendSmsService
  extend T::Sig

  sig { params(message: Message).void }
  def initialize(message)
    @message = T.let(message, Message)
  end

  sig { returns(ServiceResult) }
  def call
    return ServiceResult.failure(["Message already sent"]) if @message.status == "sent"

    Rails.logger.info "Sending SMS to #{@message.recipient_number} from #{@message.sender_number}"

    response = TwilioInteractor.new.send_sms(
      from: @message.sender_number,
      to: @message.recipient_number,
      body: @message.body,
    )

    log_success(response.sid)
    @message.update!(twilio_sid: response.sid)

    ServiceResult.success(@message)
  rescue Twilio::REST::RestError => e
    @message.update(status: "failed")

    log_failure(e)

    ServiceResult.failure(["Twilio::REST::RestError - #{e.message}"])
  rescue => e
    @message.update(status: "failed")

    log_failure(e)

    ServiceResult.failure(["Unexpected error: #{e.class} - #{e.message}"])
  end

  private

  sig { returns(Message) }
  attr_reader :message

  sig { params(sid: String).void }
  def log_success(sid)
    Rails.logger.info({
                        service: "SendSmsService",
                        message_id: @message.id.to_s,
                        status: "sent",
                        twilio_sid: sid
                      })
  end

  sig { params(error: StandardError).void }
  def log_failure(error)
    Rails.logger.error({
                         service: "SendSmsService",
                         message_id: @message.id.to_s,
                         status: "failed",
                         error_class: error.class.name,
                         error_message: error.message
                       })
  end
end
