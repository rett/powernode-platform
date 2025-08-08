FactoryBot.define do
  factory :subscription do
    account { nil }
    plan { nil }
    status { "MyString" }
    current_period_start { "2025-08-08 06:12:36" }
    current_period_end { "2025-08-08 06:12:36" }
    trial_end { "2025-08-08 06:12:36" }
    canceled_at { "2025-08-08 06:12:36" }
    ended_at { "2025-08-08 06:12:36" }
    stripe_subscription_id { "MyString" }
    paypal_subscription_id { "MyString" }
    metadata { "MyText" }
  end
end
