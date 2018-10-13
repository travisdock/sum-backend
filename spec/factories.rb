

FactoryBot.define do
    factory :user do
        sequence(:username) { |n| "tester#{n}" }
        email { "test@test.com" }
        password { "test" }
    end

    factory :user_with_data, class: 'User' do
        sequence(:username) { |n| "tester#{n}" }
        email { "test@test.com" }
        password { "test" }
        after(:create) do |user, evaluator|
            expense_category = create(:expense_category, users: [user])
            income_category = create(:income_category, users: [user])
            create_list(:expense, 2, user: user, category: expense_category)
            create_list(:income, 2, user: user, category: income_category)
        end
    end

    factory :category do
        sequence(:id) { |n| n }
        factory :expense_category do
            name { "expense_category" }
            income { false }
            untracked { false }
        end
        factory :income_category do
            name { "income_category"}
            income { true }
            untracked { false }
        end
        factory :untracked_category do
            name { "untracked_category" }
            income { false }
            untracked { true }
        end
    end

    factory :entry do
        sequence(:id) { |n| n }
        user
        date { 1.week.ago }
        amount { 15 }
        untracked { false }
        factory :expense do
            association :category, factory: :expense_category
            notes { "test expense" }
            income { false }
        end
        factory :income do
            association :category, factory: :income_category
            notes { "test income" }
            income { true }
        end
        factory :untracked do
            association :category, factory: :untracked_category
            notes { "test untracked" }
            income { false }
            untracked { true }
        end
    end
end