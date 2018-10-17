require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", type: :request do
    include RequestSpecHelper
    let(:entry) {create(:expense)}
    describe "PATCH /api/v1/entries" do

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
            #   expect(response.body).to match(//)
            end
        end
        
        context "with valid parameters (category update)" do
            let(:valid_params) do
                {
                    id: user_with_data.entries.second.id,
                    amount: 50,
                    category: "income_category"
                }
            end
            
            it "updates the entry" do
                jwt = confirm_and_login_user(user_with_data)
                patch "/api/v1/entries", params: valid_params, headers: { "Authorization" => "#{jwt}" }
                expect(response).to have_http_status(202)
            #   expect(response.body).to match(//)
            end
        end
    end
  end