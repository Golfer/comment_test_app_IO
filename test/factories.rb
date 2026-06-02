FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
  end

  factory :comment do
    association :user
    body { "A thoughtful comment" }

    trait :reply do
      association :parent, factory: :comment
    end
  end

  factory :device_token do
    association :user
    sequence(:token) { |n| "token-#{n}" }
    platform { :web }
  end
end
