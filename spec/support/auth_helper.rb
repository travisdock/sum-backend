# module AuthHelper
#     def http_login
#       user = 'travis'
#       pw = 'test'
#       request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
#     end  
#   end

  module RequestSpecHelper
    def json
      JSON.parse(response.body)
    end
  
    def confirm_and_login_user(user)
      post '/users/login', params: {username: user.username, password: "test"}
      return json['jwt']
    end
  end