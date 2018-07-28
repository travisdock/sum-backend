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
    # if @user
    #   @user.update(password: params[:password])
    #   render json: { msg: "Password Updated!" }
    # end
  end

  def charts
    render json: @user.charts
  end

  def profit_loss
    render json: @user.profit_loss
  end

  private
  def user_params
    params.permit(:username, :password, :email)
  end

  def set_user
    @user = User.find(params[:user_id])
  end


end
