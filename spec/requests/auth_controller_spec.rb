require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe 'Finances API' do
    include RequestSpecHelper

    describe 'GET /charts' do

      let(:user) {create(:user)}

      it 'responds with invalid request without JWT' do
        get "/api/v1/charts/#{user.id}"
        expect(response).to have_http_status(401)
        expect(response.body).to match(/Token Invalid/)
      end
  
      it 'responds with JSON with JWT' do
        jwt = confirm_and_login_user(user)
        get "/api/v1/charts/#{user.id}", headers: { "Authorization" => "#{jwt}" }
        expect(response).to have_http_status(200)
        expect(response.body).to match(/No Expenses/)
      end

    end
  end