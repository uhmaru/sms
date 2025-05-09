include Mongoid::Document
include Mongoid::Timestamps
class User
  include Mongoid::Document
  include Mongoid::Timestamps

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  field :remember_created_at,    type: Time

  has_many :conversations, dependent: :destroy
  has_many :messages, dependent: :destroy
end
