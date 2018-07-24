class Api::V1::EntriesController < ApplicationController


  # Custom route for getting all entries of specific user
  def index
    @user = User.find(params[:user_id])
    render json: @user.entries
  end

end
