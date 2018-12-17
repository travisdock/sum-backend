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
                patch "/api/v1/categories/#{category.id}", params: valid_params
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
                patch "/api/v1/categories/#{category.id}", params: invalid_params
                expect(response).to have_http_status(:successful)
                expect(response.body).to match(/There was an error/)
            end
        end
    end

end