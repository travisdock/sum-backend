class Api::V1::EntriesController < ApplicationController

  def create
    @user = User.find(params[:user_id])

    @category = @user.categories.select{ |category| category.name == params[:category]}[0]

    if @category
      @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category: @category, category_name: entry_params[:category], income: @category.income, gift: @category.gift)
      if @entry.save
        render json: @entry
      else
        render json: { errors: @entry.errors.full_messages }
      end
    else
      @new_category = Category.create(name: category_params[:category], income: category_params[:income], gift: category_params[:gift])
      if @new_category.save
        @user.categories << @new_category
        @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category: @new_category )
        if @entry.save
          render json: @entry
        else
          render json: { errors: @entry.errors.full_messages }
        end
      else
        render json: { errors: @new_category.errors.full_messages }
      end
    end
  end

  def delete
    @entry = Entry.find(params[:id])
    render json: @entry.destroy
  end

  def update
    @entry = Entry.find(params[:id])
    #update
  end


  private

  def entry_params
    params.permit(:user_id, :category, :date, :amount, :notes)
  end

  def category_params
    params.permit(:category, :income, :gift)
  end

end
