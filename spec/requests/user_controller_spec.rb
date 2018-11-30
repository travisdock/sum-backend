require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", :type => :request do
  include RequestSpecHelper
  describe 'GET user charts' do
    let(:user_without_data) {create(:user)}
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
    let(:lastyear_user) {create(:user_with_data, year_view: 1.year.ago.year)}
    
    it 'returns correct format for a user with expenses' do
      jwt = confirm_and_login_user(thisyear_user)
      get "/api/v1/charts/#{thisyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expense\":\"30.0\"/)
    end

    it 'returns No Expenses for a user with no expenses' do
      jwt = confirm_and_login_user(user_without_data)
      get "/api/v1/charts/#{user_without_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/No Expenses/)
    end

    it 'returns only entries from the year specified in the user table (this year)' do
      jwt = confirm_and_login_user(thisyear_user)
      get "/api/v1/charts/#{thisyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      year = Regexp.new(Time.current.year.to_s)
      expect(response.body).to match(year)
    end

    it 'returns only entries from the year specified in the user table (last year)' do
      jwt = confirm_and_login_user(lastyear_user)
      get "/api/v1/charts/#{lastyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      year = Regexp.new(1.year.ago.year.to_s)
      expect(response.body).to match(year)
    end

  end

  describe 'GET user entries' do
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
    let(:twoyear_user) {create(:user_with_data, year_view: 2.years.ago.year)}

    it 'returns all of a users entries in order beginning with most recent' do
      jwt = confirm_and_login_user(thisyear_user)
      get "/api/v1/entries/#{thisyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      entries = JSON.parse(response.body)
      expect(Date.parse(entries.first['date'])).to be < Date.parse(entries.second['date'])
    end

    it 'returns only entries from year specified in year_view' do
      jwt = confirm_and_login_user(twoyear_user)
      get "/api/v1/entries/#{twoyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      entries = JSON.parse(response.body)
      entries.each do |entry|
        expect(Date.parse(entry['date']).year).to eq(twoyear_user.year_view)
      end
    end
  end

  describe 'PATCH user' do
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
    let(:twoyear_user) {create(:user_with_data, year_view: 2.years.ago.year)}

    it 'updates the users year_view when given that info' do
      jwt = confirm_and_login_user(thisyear_user)
      expect(thisyear_user.year_view).to eq(Time.current.year)
      patch "/api/v1/users/#{thisyear_user.id}", params: {user_id: thisyear_user.id, year_view: 1.year.ago.year}, headers: { "Authorization" => "#{jwt}" }
      year = Regexp.new(1.year.ago.year.to_s)
      expect(response.body).to match(/\"year_view\":#{year}/)
      thisyear_user.reload
      expect(thisyear_user.year_view).to eq(1.year.ago.year)
    end

    it 'updates the users password when given that info' do
    
    end
  end
end