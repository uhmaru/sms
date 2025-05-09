# app/models/user.rb
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Required Devise fields for database authentication
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  # Optional Devise fields
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time
  field :remember_created_at,    type: Time

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, presence: true, uniqueness: true

  has_many :conversations, dependent: :destroy
  has_many :messages, dependent: :destroy

  def self.primary_key
    :_id
  end

  def self.jwt_revoked?(payload, user)
    false
  end

  def self.revoke_jwt(payload, user)
    # no-op
  end
end
