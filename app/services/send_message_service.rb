class SendMessageService
  def initialize(
    user:,
    recipient_number:,
    body:,
    delivery_token:,
    job_class: SendSmsJob,
    result_class: ServiceResult
  )
    @user = user
    @recipient_number = recipient_number
    @body = body
    @delivery_token = delivery_token
    @job_class = job_class
    @result_class = result_class
  end

  def call
    validate_message!

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

  def validate_message!
    allowed = Rails.configuration.x.allowed_sms_recipients
    unless allowed.include?(@recipient_number)
      raise StandardError, "Recipient number #{@recipient_number} not allowed in this environment"
    end

    if @recipient_number.blank? || @body.blank?
      raise StandardError, "Missing phone number or body"
    end
  end

  end
