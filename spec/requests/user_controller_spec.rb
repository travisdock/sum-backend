require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", :type => :request do
  include RequestSpecHelper
  include ActiveSupport::Testing::TimeHelpers
  describe 'Post user' do
    it 'creates a new user with the appropriate default year view(2001)' do
      travel_to Time.new(2001, 1, 1) do
        post "/api/v1/users",
          params: {
            username: "me",
            password: "password",
            email: "email"
          }
        end
        expect(response).to have_http_status(200)
        expect(User.last.year_view).to eq(2001)
    end
    it 'creates a new user with the appropriate default year view(current)' do
      post "/api/v1/users",
        params: {
          username: "me",
          password: "password",
          email: "email"
        }
      expect(response).to have_http_status(200)
      expect(User.last.year_view).to eq(Time.now.year)
    end
  end
  describe 'GET user charts' do
    let(:user_without_data) {create(:user)}
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
    let(:lastyear_user) {create(:user_with_data, year_view: 1.year.ago.year)}
    let(:twoyearsago_user) {create(:user_with_data, year_view: 2.years.ago.year)}
    
    it 'returns correct format for a user viewing the current year' do
      jwt = confirm_and_login_user(thisyear_user)
      get "/api/v1/charts/#{thisyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expenses\":\"60.0\"/)
      year = Regexp.new(Time.current.year.to_s)
      expect(response.body).to match(year)
    end

    it 'returns correct format for a user viewing last year' do
      jwt = confirm_and_login_user(lastyear_user)
      get "/api/v1/charts/#{lastyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expenses\":\"90.0\"/)
      year = Regexp.new(1.year.ago.year.to_s)
      expect(response.body).to match(year)
    end

    it 'returns correct format for a user viewing two years ago' do
      jwt = confirm_and_login_user(twoyearsago_user)
      get "/api/v1/charts/#{twoyearsago_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/\"Total Expenses\":\"120.0\"/)
    end

    it 'returns No Expenses for a user with no expenses' do
      jwt = confirm_and_login_user(user_without_data)
      get "/api/v1/charts/#{user_without_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/No Expenses/)
    end
  end

  describe 'GET user entries' do
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}
    let(:twoyear_user) {create(:user_with_data, year_view: 2.years.ago.year)}

    it 'returns only entries from year specified in year_view(2 years ago)' do
      jwt = confirm_and_login_user(twoyear_user)
      get "/api/v1/entries/#{twoyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      entries = JSON.parse(response.body)
      entries.each do |entry|
        expect(Date.parse(entry['date']).year).to eq(twoyear_user.year_view)
      end
    end
    it 'returns only entries from year specified in year_view(this year)' do
      jwt = confirm_and_login_user(thisyear_user)
      get "/api/v1/entries/#{thisyear_user.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      entries = JSON.parse(response.body)
      entries.each do |entry|
        expect(Date.parse(entry['date']).year).to eq(thisyear_user.year_view)
      end
    end
  end

  describe 'PATCH user' do
    let(:thisyear_user) {create(:user_with_data, year_view: Date.current.year)}

    it 'updates the users year_view when given that info' do
      jwt = confirm_and_login_user(thisyear_user)
      expect(thisyear_user.year_view).to eq(Time.current.year)
      patch "/api/v1/users/#{thisyear_user.id}",
        params: {
          user_id: thisyear_user.id,
          year_view: 1.year.ago.year
        },
        headers: { "Authorization" => "#{jwt}"}
      year = Regexp.new(1.year.ago.year.to_s)
      expect(response.body).to match(/\"year_view\":#{year}/)
      thisyear_user.reload
      expect(thisyear_user.year_view).to eq(1.year.ago.year)
    end

    it 'updates the users username when given that info' do
      jwt = confirm_and_login_user(thisyear_user)
      expect(thisyear_user.username).to include("tester")
      new_username = "new_username"
      patch "/api/v1/users/#{thisyear_user.id}",
        params: {
          user_id: thisyear_user.id,
          username: new_username
        },
        headers: { "Authorization" => "#{jwt}"}
      expect(response.body).to match(/\"username\":\"#{new_username}\"/)
      thisyear_user.reload
      expect(thisyear_user.username).to eq(new_username)
    end

    it 'does not update user if not authenticated' do
      patch "/api/v1/users/#{thisyear_user.id}",
        params: {user_id: thisyear_user.id, year_view: 1.year.ago.year}
      expect(response.body).to match(/Token Invalid/)
    end
  end
end