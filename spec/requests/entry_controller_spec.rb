require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "Entry Controller Specs", type: :request do
    include RequestSpecHelper
    
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

    describe "POST /api/v1/entries/import" do
        let(:user) {create(:user)}
        context "with a valid file it imports the entries correctly" do
            it "imports a csv file correctly maybe" do
                @file = fixture_file_upload('/files/valid-test.csv', 'text/xml')
                params = Hash.new
                params['user_id'] = user.id
                params['file'] = @file
                post '/api/v1/entries/import', params: params
                expect(response.body).to match(/Success!/)
                expect(user.entries.first.category.name).to eq("New Category")
            end
        end
    end

end
