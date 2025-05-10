class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps
  field :contact_number, type: String
  belongs_to :user
  has_many :messages, dependent: :destroy

  index({ user_id: 1, contact_number: 1 }, { unique: true })

  validates :contact_number, presence: true
  validates :user_id, presence: true
  validates :contact_number, uniqueness: { scope: :user_id }
end
