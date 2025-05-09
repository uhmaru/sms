class MessageSerializer
  def initialize(message, user_id)
    @message = message
    @user_id = user_id
  end

  def as_json(*)
    {
      id: @message.id.to_s,
      user_id: @user_id,
      phone_number: @message.sender_number,
      body: @message.body,
      direction: @message.direction,
      status: @message.status,
      created_at: @message.created_at
    }
  end
end
