class Api::V1::CategoriesController < ApplicationController

  # Custom route for getting categories of specific user
  def index
    @user = User.find(params[:user_id])
    render json: @user.categories
  end
end
