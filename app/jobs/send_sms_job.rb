# typed: strict

# typed: strict

class SendSmsJob
  include Sidekiq::Job
  extend T::Sig

  sidekiq_options queue: :default, retry: 3

  sig { params(message_id: String).void }
  def perform(message_id)
    message = Message.find(BSON::ObjectId.from_string(message_id))

    unless message.direction == "outbound"
      log_event(:warn, "skipped", message.id.to_s, {reason: "Not outbound"})
      return
    end

    unless message.status == "pending"
      log_event(:warn, "skipped", message.id.to_s, {reason: "Already processed"})
      return
    end

    result = SendSmsService.new(message).call

    if result.success?
      message.update!(status: "sent")
      log_event(:info, "sent", message.id.to_s, {})
    else
      log_event(:error, "failed", message.id.to_s, {errors: result.errors})
    end

  rescue Mongoid::Errors::DocumentNotFound
    log_event(:warn, "skipped", message_id, {reason: "Message not found"})
  rescue => e
    log_event(:error, "crashed", message_id, {
      error_class: e.class.name,
      error_message: e.message
    })
    raise e
  end

  private

  sig do
    params(
      level: Symbol,
      status: String,
      message_id: String,
      extra: T::Hash[Symbol, T.untyped]
    ).void
  end
  def log_event(level, status, message_id, extra)
    base = {
      job: "SendSmsJob",
      message_id: message_id,
      status: status
    }

    Rails.logger.public_send(level, base.merge(extra))
  end
end
