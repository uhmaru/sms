class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  field :sender_number, type: String
  field :recipient_number, type: String
  field :body, type: String
  field :direction, type: String
  field :status, type: String
  field :delivery_token, type: String
  field :sent_at, type: Time
  field :delivered_at, type: Time
  field :read_at, type: Time
  field :twilio_sid, type: String

  belongs_to :user
  belongs_to :conversation, optional: true
  has_one :webhook_log, dependent: :destroy

  index({ user_id: 1, conversation_id: 1 })
  index({ delivery_token: 1 }, unique: true, sparse: true)

  STATUSES = %w[pending sent delivered failed].freeze
  DIRECTIONS = %w[inbound outbound].freeze

  validates :recipient_number, presence: true
  validates :body, presence: true
  validates :direction, inclusion: { in: DIRECTIONS }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validates :delivery_token, presence: true, uniqueness: true
  validates :twilio_sid, uniqueness: true, allow_nil: true

  before_validation :assign_delivery_token, on: :create

  scope :inbound,  -> { where(direction: "inbound") }
  scope :outbound, -> { where(direction: "outbound") }
  scope :pending,  -> { where(status: "pending") }
  scope :sent,     -> { where(status: "sent") }
  scope :delivered,     -> { where(status: "delivered") }
  scope :failed,   -> { where(status: "failed") }

  STATUSES.each do |s|
    define_method("#{s}?") { status == s }
  end

  DIRECTIONS.each do |d|
    define_method("#{d}?") { direction == d }
  end

  private

  def assign_delivery_token
    self.delivery_token ||= SecureRandom.uuid
  end
end
