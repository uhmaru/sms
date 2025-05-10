# typed: strict

class SendMessageService
  extend T::Sig

  def initialize(
    user:,
    recipient_number:,
    body:,
    delivery_token:,
    job_class: SendSmsJob,
    result_class: ServiceResult
  )
    @user = T.let(user, User)
    @recipient_number = T.let(recipient_number, String)
    @body = T.let(body, String)
    @delivery_token = T.let(delivery_token, String)
    @job_class = T.let(job_class, T.untyped)
    @result_class = T.let(result_class, T.class_of(ServiceResult))
  end

  sig { returns(ServiceResult) }
  def call
    validation_result = validate_message!
    return validation_result if validation_result.failure?

    begin
      conversation = @user.conversations.find_or_create_by!(contact_number: @recipient_number)

      message = conversation.messages.build(
        recipient_number: @recipient_number,
        sender_number: AppConfig::TWILIO_FROM_PHONE_NUMBER,
        body: @body,
        user: @user,
        direction: "outbound",
        status: "pending",
        delivery_token: @delivery_token
      )

      if message.save
        @job_class.perform_async(message.id.to_s)
        @result_class.success(message)
      else
        @result_class.failure(message.errors.full_messages)
      end

    rescue Mongoid::Errors::Validations => e
      @result_class.failure(["Validation error: #{e.message}"])
    rescue Mongoid::Errors::DocumentNotFound => e
      @result_class.failure(["Conversation not found: #{e.message}"])
    end
  end

  sig { returns(ServiceResult) }
  def validate_message!
    allowed = Rails.configuration.x.allowed_sms_recipients

    if !allowed.include?(@recipient_number)
      return @result_class.failure([
                                     "Recipient number #{@recipient_number} not allowed in this environment"
                                   ])
    end

    if @recipient_number.blank? || @body.blank?
      return @result_class.failure(["Missing phone number or body"])
    end

    @result_class.success(nil)
  end
end
