include Mongoid::Document
include Mongoid::Timestamps
class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  field :contact_number, type: String
  belongs_to :user
  has_many :messages, dependent: :destroy

  index({ user_id: 1, contact_number: 1 }, { unique: true })
end
