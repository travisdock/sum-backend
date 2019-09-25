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

  private
  def user_params
    params.permit(:username, :password, :email)
  end

  def update_params
    params.permit(:username, :password, :email, :year_view)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_year_view
    @user.year_view = Time.now.year
    @user.save
  end
end
