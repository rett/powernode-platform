FactoryBot.define do
  factory :user do
    account { nil }
    email { "MyString" }
    first_name { "MyString" }
    last_name { "MyString" }
    password_digest { "MyString" }
    role { "MyString" }
    status { "MyString" }
    last_login_at { "2025-08-08 06:00:32" }
    email_verified_at { "2025-08-08 06:00:32" }
  end
end
