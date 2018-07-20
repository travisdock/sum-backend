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

  def totals
    @user = User.find(params[:user_id])
    render json: @user.get_totals
  end
end
