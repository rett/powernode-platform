FactoryBot.define do
  factory :user do
    association :account
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { 'SecureFactoryCode$9!' }
    role { 'member' }
    status { 'active' }
    email_verified_at { 1.day.ago }

    trait :owner do
      role { 'owner' }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :member do
      role { 'member' }
    end

    trait :inactive do
      status { 'inactive' }
    end

    trait :suspended do
      status { 'suspended' }
    end

    trait :unverified do
      email_verified_at { nil }
    end

    trait :with_roles do
      after(:create) do |user|
        role = create(:role, name: user.role.capitalize)
        user.roles << role
      end
    end
  end
end
