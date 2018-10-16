require 'rails_helper'
require_relative '../support/auth_helper'

RSpec.describe "User Controller Specs", type: :request do
    include RequestSpecHelper
    
    describe "PATCH /api/v1/entries" do
      context "with valid parameters" do
        let(:valid_params) do
          {
             entry: {}
          }
        end
  
        it "updates the entry" do
          expect { post "/api/v1/entries", params: valid_params }.to )
          expect(response).to have_http_status(202)
        #   expect(response.headers['Location']).to eq api_v1_bathroom_url(Bathroom.last)
        end
      end
  
      context "with invalid parameters" do
         # testing for validation failures is just as important!
         # ...
      end
    end
  end