require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "Auth Conroller Specs", :type => :request do
  include RequestSpecHelper

  describe 'Login' do
    let(:user) {create(:user)}

    it 'responds with Username or Password invalid when incorrect login credentials used' do
      body = {username: "wrong", password: "incorrect"}
      post "/api/v1/login",
      params: body.to_json,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }
      expect(response).to have_http_status(401)
    end

    it 'responds with a token when correct login credentials used' do
      body = {username: user.username, password: user.password}
      post "/api/v1/login",
      params: body.to_json,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"jwt\":/)
    end
  end

  describe 'GET user data' do

    let(:user) {create(:user)}

    it 'responds with invalid request without a valid JWT token' do
      get "/api/v1/charts/#{user.id}"
      expect(response).to have_http_status(401)
      expect(response.body).to match(/Token Invalid/)
    end

    it 'responds with JSON to a request with a valid JWT' do
      jwt = confirm_and_login_user(user)
      get "/api/v1/charts/#{user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/No Expenses/)
    end

  end
end