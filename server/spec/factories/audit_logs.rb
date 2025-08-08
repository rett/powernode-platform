FactoryBot.define do
  factory :audit_log do
    user { nil }
    account { nil }
    action { "MyString" }
    resource_type { "MyString" }
    resource_id { "MyString" }
    old_values { "MyText" }
    new_values { "MyText" }
    metadata { "MyText" }
    ip_address { "MyString" }
    user_agent { "MyString" }
  end
end
