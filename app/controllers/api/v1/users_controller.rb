class Api::V1::UsersController < ApplicationController
  before_action :set_user, except: [:create]
  
  after_action :set_year_view, only: [:create]

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
      if @user.update(update_params)
        render json: {
          username: @user.username,
          id: @user.id,
          categories: @user.current_categories,
          year_view: @user.year_view,
          years: @user.years
        }
      else
        render json: {error: 'update error...'}
      end
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
            date: DateTime.new(@user.year_view).beginning_of_year..DateTime.new(@user.year_view
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

  def set_year_view
    @user.year_view = Time.now.year
    @user.save
  end

end
