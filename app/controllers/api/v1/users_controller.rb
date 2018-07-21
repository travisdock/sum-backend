class Api::V1::UsersController < ApplicationController

  def create
    @user = User.create(user_params)
    if @user
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

  def month_category
    @user = User.find(params[:user_id])
    render json: @user.formatted_month_category
  end

  def totals_averages
    @user = User.find(params[:user_id])
    render json: @user.formatted_totals_averages
  end


end
