require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "Entry Controller Specs", type: :request do
    include RequestSpecHelper

    describe "POST /api/v1/entries" do
        before(:each) do
            @user = create(:user)
        end

        context "when logged in and with valid parameters" do
            let(:valid_params) do
                {
                    user_id: @user.id,
                    date: "1/12/18",
                    amount: "1.25",
                    notes: "this is a test entry",
                    category_name: "test category",
                    income: false,
                    untracked: false

                }
            end
            it "creates a new entry and category" do
                jwt = confirm_and_login_user(@user)
                post "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                expect(response.body).to match(/test category/)
                expect(@user.categories.length).to eq(1)
                expect(@user.entries.length).to eq(1)
            end
        end

        context "when logged in but with an invalid entry" do
            let(:invalid_params) do
                {
                    user_id: @user.id,
                    date: "1/12/18",
                    notes: "test entry #2",
                    category_name: "test category #2",
                    income: false,
                    untracked: false
                }
            end
            it "responds with appropriate errors and does not create entry or category" do
                jwt = confirm_and_login_user(@user)
                post "/api/v1/entries", params: invalid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response.body).to match(/errors/)
                expect(@user.categories.length).to eq(0)
                expect(Category.all.length).to eq(0)
                expect(@user.entries.length).to eq(0)
                expect(Entry.all.length).to eq(0)
            end
        end

        context "when not logged in responds appropriately" do
            let(:valid_params) do
                {
                    user_id: @user.id,
                    date: "1/12/18",
                    amount: "1.25",
                    notes: "this is a test entry",
                    category_name: "test category",
                    income: false,
                    untracked: false

                }
            end
            it "creates a new entry and category" do
                post "/api/v1/entries", params: valid_params
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
                expect(user_with_data.entries.second.id).to eq(10)
                delete "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(200)
                expect(user_with_data.entries.second.id).to_not eq(10)
            end
        end
        context "given an invalidated user" do
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
                @file = fixture_file_upload('/files/valid-test.csv', 'text/xml')
                params = Hash.new
                params['user_id'] = user.id
                params['file'] = @file
                post '/api/v1/entries/import', params: params
                expect(response.body).to match(/Success!/)
                expect(user.categories.length).to eq(1)
                expect(user.entries.first.category.name).to eq("New Category")
                expect(user.entries.length).to eq(1)
            end
        end
        context "given an invalid csv file" do
            it "gives the proper error messaging and does not add anything to the users categories or entries" do
                @file = fixture_file_upload('/files/invalid-test.csv', 'text/xml')
                params = Hash.new
                params['user_id'] = user.id
                params['file'] = @file
                post '/api/v1/entries/import', params: params
                expect(response.body).to match(/Error/)
                expect(user.categories.length).to eq(0)
                expect(user.entries.length).to eq(0)
            end
        end
    end
end
