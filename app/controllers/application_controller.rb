class ApplicationController < ActionController::API
  # before_action :authorized
  #add auth to every route

  def issue_token(payload)
    JWT.encode(payload, ENV["jwt_token_secret"], 'HS256')
  end

  def current
    @user ||= User.find_by(id: user_id)
  end

  def user_id
    decoded_token[0]['user_id']
  end

  def decoded_token
    begin
      JWT.decode(request.headers['Authorization'], 'learnlovecode', true, {algorithm: 'HS256'})
    rescue JWT::DecodeError
      [{}]
    end
  end

  def authorized
    render json: {message: "No valid token"}, status: 401 unless logged_in
  end

  def logged_in
    !!current
  end

end
