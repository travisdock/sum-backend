class EntriesController < ApplicationController

  def index
    @user = User.find(params[:user_id])
    render json: @user.entries
  end

end
