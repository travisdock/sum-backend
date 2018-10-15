require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", :type => :request do
  include RequestSpecHelper
  describe 'GET user charts' do

    let(:user_with_data) {create(:user)}
    let(:user_without_data) {create(:user)}
    let(:expense_category) {create(:expense_category)}
    let(:income_category) {create(:income_category)}
    

    it 'returns correct format for a user with expenses' do
      expense_category.users = [user_with_data]
      income_category.users = [user_with_data]
      create_list(:expense, 2, user: user_with_data, category: expense_category)
      create_list(:income, 2, user: user_with_data, category: income_category)
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

    let(:user_with_data) {create(:user)}
    let(:expense_category) {create(:expense_category)}
    let(:income_category) {create(:income_category)}

    it 'returns all of a users entries in a specific order' do
      expense_category.users = [user_with_data]
      income_category.users = [user_with_data]
      create_list(:expense, 2, user: user_with_data, category: expense_category)
      create_list(:income, 2, user: user_with_data, category: income_category)
      jwt = confirm_and_login_user(user_with_data)
      get "/api/v1/entries/#{user_with_data.id}", headers: { "Authorization" => "#{jwt}" }
      expect(response).to have_http_status(200)
      expect(response.body).to match(/amount\":\"15.0\",\"notes\":\"test income\",\"created_at\":/)
    end
  end
end