FactoryBot.define do
    factory :user do
        sequence(:username) { |n| "tester#{n}" }
        email { "test@test.com" }
        password { "test" }
        factory :user_with_data do
            after(:create) do |user, evaluator|
                # Create categories for all three years
                this_year_expense_category = create(:expense_category, users: [user])
                this_year_income_category = create(:income_category, users: [user])
                last_year_expense_category = create(:expense_category, users: [user], year: 1.year.ago.year)
                last_year_income_category = create(:income_category, users: [user], year: 1.year.ago.year)
                two_years_ago_expense_category = create(:expense_category, users: [user], year: 2.years.ago.year)
                two_years_ago_income_category = create(:income_category, users: [user], year: 2.years.ago.year)
                # Create expenses over three year period
                create_list(:this_year_expense, 4, user: user, category: this_year_expense_category)
                create_list(:last_year_expense, 6, user: user, category: last_year_expense_category)
                create_list(:two_years_ago_expense, 8, user: user, category: two_years_ago_expense_category)
                # Create income entries over 3 year period
                create_list(:this_year_income, 4, user: user, category: this_year_income_category)
                create_list(:last_year_income, 6, user: user, category: last_year_income_category)
                create_list(:two_years_ago_income, 8, user: user, category: two_years_ago_income_category)
            end
        end
    end

    factory :category do
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
        user
        date { 1.week.ago }
        amount { 15 }
        untracked { false }
        factory :expense do
            association :category, factory: :expense_category
            notes { "test expense" }
            income { false }
            factory :this_year_expense do
                date { Faker::Date.between(Time.now.beginning_of_year, Time.now.end_of_year) }
            end
            factory :last_year_expense do
                date { Faker::Date.between(1.year.ago.beginning_of_year, 1.year.ago.end_of_year) }
            end
            factory :two_years_ago_expense do
                date { Faker::Date.between(2.years.ago.beginning_of_year, 2.years.ago.end_of_year) }
            end
        end
        factory :income do
            association :category, factory: :income_category
            notes { "test income" }
            income { true }
            factory :this_year_income do
                date { Faker::Date.between(Time.now.beginning_of_year, Time.now.end_of_year) }
            end
            factory :last_year_income do
                date { Faker::Date.between(1.year.ago.beginning_of_year, 1.year.ago.end_of_year) }
            end
            factory :two_years_ago_income do
                date { Faker::Date.between(2.years.ago.beginning_of_year, 2.years.ago.end_of_year) }
            end
        end
        factory :untracked do
            association :category, factory: :untracked_category
            notes { "test untracked" }
            income { false }
            untracked { true }
        end
    end
end