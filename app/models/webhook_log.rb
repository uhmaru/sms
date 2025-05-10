class WebhookLog
  include Mongoid::Document
  include Mongoid::Timestamps
  field :twilio_sid, type: String
  field :status, type: String
  field :raw_data, type: Hash
  belongs_to :message

  index({ twilio_sid: 1 }, { unique: true })
end
