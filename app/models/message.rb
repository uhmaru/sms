class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :phone_number, type: String
  field :body, type: String
  field :direction, type: String
  field :status, type: String
  field :twilio_sid, type: String
  belongs_to :user
  belongs_to :conversation
end
