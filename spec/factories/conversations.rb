FactoryBot.define do
  factory :conversation do
    contact_number { Faker::PhoneNumber.cell_phone }
    association :user
  end
end
