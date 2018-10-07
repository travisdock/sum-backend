require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", :type => :request do
  include RequestSpecHelper
  describe 'GET user correct user charts' do

    let(:user_with_data) {create(:user_with_data)}
    let(:user_without_data) {create(:user)}

    it 'returns correct format' do
      jwt = confirm_and_login_user(user_with_data)
      get "/api/v1/charts/#{user_with_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expense\":\"30.0\"/)
    end

    it 'returns correct format' do
        jwt = confirm_and_login_user(user_without_data)
        get "/api/v1/charts/#{user_without_data.id}", headers: { "Authorization" => "#{jwt}" }
        expect(response).to have_http_status(200)
        expect(response.body).to match(/No Expenses/)
      end

  end
end