class Api::V1::CategoriesController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    render json: @user.categories
  end
end
