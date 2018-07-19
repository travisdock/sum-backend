class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    render json: @user
  end

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
end
