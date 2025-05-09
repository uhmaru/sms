include Mongoid::Document
include Mongoid::Timestamps
class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :phone_number, type: String
  field :body, type: String
  field :direction, type: String
  field :status, type: String
  field :twilio_sid, type: String
  belongs_to :user
  belongs_to :conversation, optional: true
  has_one :webhook_log, dependent: :destroy

  index({ user_id: 1, conversation_id: 1 })
  index({ twilio_sid: 1 }, { unique: true })
end
