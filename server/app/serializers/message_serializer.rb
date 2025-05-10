# typed: strict

class MessageSerializer
  extend T::Sig

  sig { params(message: Message, user_id: String).void }
  def initialize(message, user_id)
    @message = T.let(message, Message)
    @user_id = T.let(user_id, String)
  end

  sig { params(args: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
  def as_json(*args)
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
