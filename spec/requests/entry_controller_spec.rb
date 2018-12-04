require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "Entry Controller Specs", type: :request do
    include RequestSpecHelper

    describe "POST /api/v1/entries" do
        context "when logged in and with valid parameters" do
        let(:user_without_data) {create(:user, year_view: Date.current.year)}
        let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
            it "creates a new entry and category last year" do
                jwt = confirm_and_login_user(user_without_data)
                expect(user_without_data.categories.length).to eq(0)
                expect(user_without_data.entries.length).to eq(0)
                post "/api/v1/entries",
                    params: attributes_for(
                        :last_year_expense,
                        user_id: user_without_data.id,
                        category_name: "test category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                # Categories does not have anything because the category was added to last year
                expect(response.body).to match(/\"categories\":\[\]/)
                # Year view should be this year and years should include last year
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{last_year}\]/)
                user_without_data.reload
                expect(user_without_data.categories.length).to eq(1)
                expect(user_without_data.entries.length).to eq(1)
            end
            it "can create a new entry and category this year" do
                jwt = confirm_and_login_user(user_without_data)
                expect(user_without_data.categories.length).to eq(0)
                expect(user_without_data.entries.length).to eq(0)
                post "/api/v1/entries",
                    params: attributes_for(
                        :this_year_expense,
                        user_id: user_without_data.id,
                        category_name: "test category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                # Year view should be this year and years should include last year
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{this_year}\]/)
                user_without_data.reload
                expect(user_without_data.categories.length).to eq(1)
                expect(user_without_data.entries.length).to eq(1)
            end
            it "can create a new entry from old category last year" do
                jwt = confirm_and_login_user(thisyear_user)
                expect(thisyear_user.categories.length).to eq(6)
                expect(thisyear_user.entries.length).to eq(36)
                post "/api/v1/entries",
                    params: attributes_for(
                        :last_year_expense,
                        user_id: thisyear_user.id,
                        category_name: "expense_category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                two_years_ago = Regexp.new(2.years.ago.year.to_s)
                # Year view should be this year and years should include all years
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{two_years_ago},#{last_year},#{this_year}\]/)
                thisyear_user.reload
                # Categories stay the same
                expect(thisyear_user.categories.length).to eq(6)
                # Entries increase
                expect(thisyear_user.entries.length).to eq(37)
            end
            it "can create a new entry from old category this year" do
                jwt = confirm_and_login_user(thisyear_user)
                expect(thisyear_user.categories.length).to eq(6)
                expect(thisyear_user.entries.length).to eq(36)
                post "/api/v1/entries",
                    params: attributes_for(
                        :this_year_expense,
                        user_id: thisyear_user.id,
                        category_name: "expense_category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                two_years_ago = Regexp.new(2.years.ago.year.to_s)
                # Year view should be this year and years should include all years
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{two_years_ago},#{last_year},#{this_year}\]/)
                thisyear_user.reload
                # Categories stay the same
                expect(thisyear_user.categories.length).to eq(6)
                # Entries increase
                expect(thisyear_user.entries.length).to eq(37)
            end
            it "can create a new entry and category next year" do
                jwt = confirm_and_login_user(thisyear_user)
                expect(thisyear_user.categories.length).to eq(6)
                expect(thisyear_user.entries.length).to eq(36)
                post "/api/v1/entries",
                    params: attributes_for(
                        :next_year_expense,
                        user_id: thisyear_user.id,
                        category_name: "test_category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                two_years_ago = Regexp.new(2.years.ago.year.to_s)
                next_year = Regexp.new(1.year.from_now.year.to_s)
                # Year view should be this year and years should include all years
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{two_years_ago},#{last_year},#{this_year},#{next_year}\]/)
                thisyear_user.reload
                # Categories increase
                expect(thisyear_user.categories.length).to eq(7)
                # Entries increase
                expect(thisyear_user.entries.length).to eq(37)
            end
            it "can create a new entry from old category next year" do
                next_year_expense_category = create(:expense_category, users: [thisyear_user], year: 1.year.from_now.year)
                jwt = confirm_and_login_user(thisyear_user)
                expect(thisyear_user.categories.length).to eq(7)
                expect(thisyear_user.entries.length).to eq(36)
                post "/api/v1/entries",
                    params: attributes_for(
                        :next_year_expense,
                        user_id: thisyear_user.id,
                        category_name: "expense_category"
                        ).except!(:id),
                    headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                this_year = Regexp.new(Time.current.year.to_s)
                last_year = Regexp.new(1.year.ago.year.to_s)
                two_years_ago = Regexp.new(2.years.ago.year.to_s)
                next_year = Regexp.new(1.year.from_now.year.to_s)
                # Year view should be this year and years should include all years
                expect(response.body).to match(/"year_view\":#{this_year},\"years\":\[#{two_years_ago},#{last_year},#{this_year},#{next_year}\]/)
                thisyear_user.reload
                # Categories stay the same
                expect(thisyear_user.categories.length).to eq(7)
                # Entries increase
                expect(thisyear_user.entries.length).to eq(37)
            end
        end

        context "when logged in but with an invalid entry" do
            let(:user) {create(:user)}
            # No amount value should result in error
            let(:invalid_params) do
                {
                    user_id: user.id,
                    date: Date.today.to_s,
                    notes: "test entry #2",
                    category_name: "test category #2",
                    income: false,
                    untracked: false
                }
            end
            it "responds with appropriate errors and does not create entry or category" do
                jwt = confirm_and_login_user(user)
                post "/api/v1/entries", params: invalid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response.body).to match(/errors/)
                expect(user.categories.length).to eq(0)
                expect(Category.all.length).to eq(0)
                expect(user.entries.length).to eq(0)
                expect(Entry.all.length).to eq(0)
            end
        end

        context "when not logged" do
            let(:user) {create(:user)}
            it "responds with invalid token error" do
                post "/api/v1/entries",
                    params: attributes_for(
                            :this_year_expense,
                            user_id: user.id,
                            category_name: "expense_category"
                            ).except!(:id)
                expect(response).to have_http_status(401)
                expect(response.body).to match(/Token Invalid/)
            end
        end
    end
    
    describe "PATCH /api/v1/entries" do
        let(:entry) {create(:expense)}
        let(:user_with_data) {create(:user_with_data)}

        context "with valid parameters (no category update)" do
            let(:valid_params) do
                {
                    id: user_with_data.entries.first.id,
                    amount: 45
                }
            end

            it "updates the entry" do
                jwt = confirm_and_login_user(user_with_data)
                patch "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(202)
                expect(response.body).to match(/"amount\":\"45.0\"/)
                expect(user_with_data.entries.first.amount).to eq(45)
            end
        end
        
        context "with valid parameters (category update)" do
            let(:valid_params) do
                {
                    id: user_with_data.entries.second.id,
                    amount: 50,
                    category_name: "income_category",
                    category_id: user_with_data.entries.second.category.id,
                    income: user_with_data.entries.second.income
                }
            end
            
            it "updates the entry" do
                jwt = confirm_and_login_user(user_with_data)
                expect(user_with_data.entries.second.amount).to eq(15)
                patch "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(202)
                expect(response.body).to match(/\"category_name\":\"income_category\"/)
                expect(response.body).to match(/\"income\":true,\"untracked\":false/)
                expect(user_with_data.entries.second.category_name).to eq("income_category")
                expect(user_with_data.entries.second.category_id).to eq(Category.where(name: "income_category").first.id)
            end
        end
    end

    describe "DELETE /api/v1/entries" do
        let(:user_with_data) {create(:user_with_data)}
        let(:valid_params) do
            { id: user_with_data.entries.second.id }
        end
        context "given a validated user with data deletes an entry" do
            it "deletes the entry" do
                jwt = confirm_and_login_user(user_with_data)
                expect(user_with_data.entries.length).to eq(36)
                delete "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                user_with_data.reload
                expect(user_with_data.entries.length).to eq(35)
            end
        end
        context "given an invalid user" do
            it "responds with appropriate error" do
                delete "/api/v1/entries", params: valid_params
                expect(response).to have_http_status(401)
            end
        end
    end

    describe "POST /api/v1/entries/import" do
        let(:user) {create(:user)}
        context "given a valid csv file" do
            it "imports it as expected and adds the entry and category" do
                jwt = confirm_and_login_user(user)
                @file = fixture_file_upload('/files/valid-test.csv', 'text/xml')
                params = Hash.new
                params['user_id'] = user.id
                params['file'] = @file
                post '/api/v1/entries/import', params: params, headers: { "Authorization" => "#{jwt}" }
                expect(response.body).to match(/Success!/)
                expect(user.categories.length).to eq(1)
                expect(user.entries.first.category.name).to eq("New Category")
                expect(user.entries.length).to eq(1)
            end
        end
        context "given an invalid csv file" do
            it "gives the proper error messaging and does not add to the users categories or entries" do
                jwt = confirm_and_login_user(user)
                @file = fixture_file_upload('/files/invalid-test.csv', 'text/xml')
                params = Hash.new
                params['user_id'] = user.id
                params['file'] = @file
                post '/api/v1/entries/import', params: params, headers: { "Authorization" => "#{jwt}" }
                expect(response.body).to match(/Error/)
                expect(user.categories.length).to eq(0)
                expect(user.entries.length).to eq(0)
            end
        end
    end
end
