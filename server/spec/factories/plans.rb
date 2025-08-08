FactoryBot.define do
  factory :plan do
    name { "MyString" }
    description { "MyText" }
    price_cents { 1 }
    currency { "MyString" }
    billing_cycle { "MyString" }
    features { "MyText" }
    limits { "MyText" }
    status { "MyString" }
    default_roles { "MyText" }
  end
end
