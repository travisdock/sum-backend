

FactoryBot.define do
    factory :user do
        sequence(:username) { |n| "tester#{n}" }
        email { "test@test.com" }
        password { "test" }
    end
end