require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", :type => :request do
  include RequestSpecHelper
  describe 'GET user charts' do

    let(:user_with_data) {create(:user_with_data)}
    let(:user_without_data) {create(:user)}
    
    it 'returns correct format for a user with expenses' do
      jwt = confirm_and_login_user(user_with_data)
      get "/api/v1/charts/#{user_with_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expense\":\"30.0\"/)
    end

    it 'returns No Expenses for a user with no expenses' do
      jwt = confirm_and_login_user(user_without_data)
      get "/api/v1/charts/#{user_without_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/No Expenses/)
    end

  end

  describe 'GET user entries' do

    let(:user_with_data) {create(:user_with_data)}

    it 'returns all of a users entries in order beginning with most recent' do
      jwt = confirm_and_login_user(user_with_data)
      get "/api/v1/entries/#{user_with_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      entries = JSON.parse(response.body)
      expect(Date.parse(entries.first['date'])).to be < Date.parse(entries.second['date'])
      expect(Date.parse(entries.second['date'])).to be < Date.parse(entries.laste['date'])
    end
  end
end