# spec/factories/messages.rb
FactoryBot.define do
  factory :message do
    association :user
    association :conversation

    sender_number    { "+15556667777" }
    recipient_number { "+15558889999" }
    body             { "Hello from FactoryBot!" }
    direction        { "outbound" }
    status           { "pending" }
    delivery_token   { SecureRandom.uuid }
    twilio_sid { "SM123456" }

    sent_at          { nil }
    delivered_at     { nil }
    read_at          { nil }

    trait :inbound do
      direction { "inbound" }
    end

    trait :outbound do
      direction { "outbound" }
    end

    trait :sent do
      status   { "sent" }
      sent_at  { Time.current }
    end

    trait :failed do
      status { "failed" }
    end

    trait :delivered do
      delivered_at { Time.current }
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
