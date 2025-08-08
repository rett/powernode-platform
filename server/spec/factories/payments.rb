FactoryBot.define do
  factory :payment do
    invoice { nil }
    amount_cents { 1 }
    currency { "MyString" }
    status { "MyString" }
    payment_method { "MyString" }
    stripe_payment_intent_id { "MyString" }
    stripe_charge_id { "MyString" }
    paypal_order_id { "MyString" }
    paypal_capture_id { "MyString" }
    processed_at { "2025-08-08 06:18:01" }
    failed_at { "2025-08-08 06:18:01" }
    failure_reason { "MyString" }
    metadata { "MyText" }
  end
end
