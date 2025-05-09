# app/jobs/update_message_status_job.rb
class UpdateMessageStatusJob
  include Sidekiq::Job

  def perform(message_id, new_status)
    message = Message.find(message_id)
    MessageStatusUpdaterService.new(message, new_status).call
  end
end
