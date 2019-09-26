class Api::V2::UsersController < ApplicationController
    before_action :set_user

    def v2charts
      if logged_in
        render json: @user.v2charts, status: 200
      else
        render json: {error: 'Token Invalid'}, status: 401
      end
    end
end