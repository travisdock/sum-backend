class Api::V1::AuthController < ApplicationController
  # skip_before_action :authorized, only: [:create, :show]

  def create
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
      token = issue_token({id: user.id})
      render json: {
        username: user.username,
        id: user.id, jwt: token,
        categories: user.categories,
        year_view: user.year_view,
        years: user.years
        }, status: 200
    else
      render json: {error: 'Username or Password Invalid'}, status: 401
    end
  end

  def show
    if logged_in
      render json: {
        username: current.username,
        id: current.id,
        categories: current.categories,
        year_view: current.year_view,
        years: current.years
        }, status: 200
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end

end
