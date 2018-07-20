class EntriesController < ApplicationController
  before_action :authenticate_user
  
  def index
    @user = User.find(params[:user_id])
    render json: @user.entries
  end

end
