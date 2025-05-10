# app/channels/messages_channel.rb
class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_#{params[:conversation_id]}"
  end

  def unsubscribed
    # Cleanup
  end
end
