class Api::V1::UsersController < ApplicationController
  before_action :set_user, except: [:create]

  def create
    @user = User.create(user_params)
    if @user.valid?
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }
    end
  end

  def update
    if logged_in
      @user.update(update_params)
      render json: @user
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end

  def charts
    if logged_in
      render json: @user.charts, status: 200
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
    
  end

  def entries
    if logged_in
      render json: 
        @user
          .entries
          .where(
            date: Date.commercial(@user.year_view).beginning_of_year..Date.commercial(@user.year_view
            ).end_of_year
          ).reverse,
          status: 200
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
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


end
