class Api::V1::EntriesController < ApplicationController

  def create
    if logged_in
      @user = User.find(params[:user_id])

      @category = @user.categories.select{ |category| category.name == params[:category]}[0]

      if @category
        @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category: @category, category_name: entry_params[:category], income: @category.income, untracked: @category.untracked)
        if @entry.save
          render json: @entry
        else
          render json: { errors: @entry.errors.full_messages }
        end
      else
        @new_category = Category.create(name: category_params[:category], income: category_params[:income], untracked: category_params[:untracked])
        if @new_category.save
          @user.categories << @new_category
          @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category: @new_category, category_name: entry_params[:category], income: @new_category.income, untracked: @new_category.untracked)
          if @entry.save
            render json: @user.categories
          else
            render json: { errors: @entry.errors.full_messages }
          end
        else
          render json: { errors: @new_category.errors.full_messages }
        end
      end
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end

  def delete
    if logged_in
      @entry = Entry.find(params[:id])
      render json: @entry.destroy, status: 200
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end

  def update
    if logged_in
      @entry = Entry.find(params[:id])

      if @entry
        if params[:category]
          @category = @user.categories.select{ |category| category.name == params[:category]}[0]
          params[:category] = @category
          params[:category_name] = @category.name
          if @entry.update(entry_params)
            render json: @entry, status: 202
          else
            render json: {error: 'Update did not succeed, not valid category update.'}, status: 204
          end
        elsif @entry.update(entry_params)
          render json: @entry, status: 202
        else
          render json: {error: 'Update did not succeed, not valid entry update.'}, status: 204
        end
      else
        render json: {error: 'Update did not succeed, not valid entry.'}, status: 204
      end
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end


  private

  def entry_params
    params.permit(:user_id, :category, :date, :amount, :notes, :category_name)
  end

  def category_params
    params.permit(:category, :income, :untracked)
  end

end
