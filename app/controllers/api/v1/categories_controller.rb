class Api::V1::CategoriesController < ApplicationController

    def create
        # TODO
    end

    def update
        @user = User.find(params[:user_id])
        @category = Category.find(params[:id])
        if @category.update(update_params)
            @category.entries.each do |entry|
                entry.update(
                    category_name: @category.name,
                    income: @category.income,
                    untracked: @category.untracked,
                    date: entry.date.change(:year => @category.year)
                )
            end
            render json: {
              username: @user.username,
              id: @user.id,
              categories: @user.current_categories,
              year_view: @user.year_view,
              years: @user.years
            }
        else
            render json: {
                errors: "There was an error: #{@category.errors.full_messages}"
            }
        end
    end

    def destroy
        @user = User.find(params[:user_id])
        @category = Category.find(params[:id])
        @category.destroy
        render json: {
              username: @user.username,
              id: @user.id,
              categories: @user.current_categories,
              year_view: @user.year_view,
              years: @user.years
            }
    end

    private

    def update_params
        params.permit(:name, :income, :untracked, :year)
    end
end
