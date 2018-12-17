require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "Category Controller Spec", type: :request do
    include RequestSpecHelper
    
    describe "PATCH api/v1/categories/:id" do
        let(:user_with_data) {create(:user_with_data)}
        let(:category) { user_with_data.categories.first }

        context "with valid params" do

            let(:valid_params) do
                {
                    user_id: user_with_data.id,
                    name: "new name",
                    income: category.income,
                    untracked: category.untracked,
                    year: category.year
                }
            end
            it "updates the given category and returns user update info" do
                jwt = confirm_and_login_user(user_with_data)
                patch "/api/v1/categories/#{category.id}", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(:successful)
                category.reload
                expect(category.name).to eq(valid_params[:name])
            end
        end

        context "with invalid params" do
            let(:invalid_params) do
                {
                    user_id: user_with_data.id,
                    name: category.name,
                    income: category.income,
                    untracked: category.untracked,
                    year: "invalid string"
                }
            end
            it "responds with an error message" do
                jwt = confirm_and_login_user(user_with_data)
                patch "/api/v1/categories/#{category.id}", params: invalid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(:successful)
                expect(response.body).to match(/There was an error/)
            end
        end
    end

    describe "DELETE /api/v1/categories/:id" do
        let(:user_with_data) {create(:user_with_data)}
        let(:category) { user_with_data.categories.first }
        
        context "with valid params" do
            let(:valid_params) do
                {
                    user_id: user_with_data.id
                }
            end
            it "deletes given category and responds" do
                jwt = confirm_and_login_user(user_with_data)
                expect(user_with_data.categories.length).to eq(6)
                delete "/api/v1/categories/#{category.id}", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(:successful)
                user_with_data.reload
                expect(user_with_data.categories.length).to eq(5)
            end
        end
    end

end