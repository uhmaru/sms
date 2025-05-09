FactoryBot.define do
  factory :webhook_log do
    twilio_sid { SecureRandom.uuid }
    status { "delivered" }
    raw_data { { payload: "example" } }
    association :message
  end
end
