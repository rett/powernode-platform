FactoryBot.define do
  factory :payment_method do
    account { nil }
    user { nil }
    provider { "MyString" }
    external_id { "MyString" }
    payment_type { "MyString" }
    last_four { "MyString" }
    expires_at { "2025-08-08 06:24:08" }
    is_default { false }
    metadata { "MyText" }
  end
end
