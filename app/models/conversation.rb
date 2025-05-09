class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  field :contact_number, type: String
  belongs_to :user
end
