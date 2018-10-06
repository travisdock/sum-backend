require 'rails_helper'
require_relative '../support/auth_helper'

# RSpec.describe "Auth", type: :request do
#     describe 'GET /charts' do
#         include AuthHelper
#         before(:each) do
#             http_login
#             User.ceate(username: "travis", password: "test", id: 1)
#         end
#         # before do
#         #     basic_auth 'travis', 'test'
#         #     User.ceate(username: "travis", password: "test", id: 1)
#         # end
#         it 'does authenticate' do
#             get '/api/v1/charts/1'
    
#             # test for the 200 status-code
#             expect(response).to be_success
#         end
#     end
# end

RSpec.describe 'Finances API' do
    include RequestSpecHelper
    
  
    describe 'GET /charts' do
      user = User.create(username: "travis", password: "test", email: "test", id: 1)

      it 'responds with invalid request without JWT' do
        get '/api/v1/charts/1' 
        expect(response).to have_http_status(401)
        expect(response.body).to match(/Invalid Request/)
      end
  
      it 'responds with JSON with JWT' do
        jwt = confirm_and_login_user(user)
        get '/api/v1/charts/1', headers: { "Authorization" => "Bearer #{jwt}" }
        expect(response).to have_http_status(200)
        expect(json.size).to eq(10)
      end
    end
  end