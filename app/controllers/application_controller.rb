class ApplicationController < ActionController::API

  def issue_token(payload)
    JWT.encode(payload, ENV["jwt_token_secret"], 'HS256')
  end

  def current
    @user = User.find_by(id: user_id)
  end

  def user_id
    decoded_token[0]['id']
  end

  def decoded_token
    begin
      JWT.decode(request.headers['Authorization'], ENV["jwt_token_secret"], true, {algorithm: 'HS256'})
    rescue JWT::DecodeError
      [{}]
    end
  end

  def logged_in
    !!current
  end

end
