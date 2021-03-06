class Api::V1::EntriesController < ApplicationController

  def create
    if logged_in
      @user = User.find(params[:user_id])
      entry_year = DateTime.parse(params[:date]).year
      category_with_date = @user.categories.select{ |cat| cat.name == params[:category_name] && cat.year == entry_year}[0]
      category_without_date = @user.categories.select{ |cat| cat.name == params[:category_name] }[0]

      if category_with_date
        @category = category_with_date
      elsif category_without_date
        @category = category_without_date.dup
        @category.year = entry_year
        @category.save
        @user.categories << @category
      end

      if @category
        @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category_id: @category.id, category_name: @category.name, income: @category.income, untracked: @category.untracked)
        if @entry.save
          render json: {
            username: @user.username,
            id: @user.id,
            categories: @user.current_categories,
            year_view: @user.year_view,
            years: @user.years
          }
        else
          render json: { errors: @entry.errors.full_messages }
        end
      else
        @new_category = Category.create(
          name: category_params[:category_name],
          income: category_params[:income],
          untracked: category_params[:untracked],
          year: DateTime.parse(entry_params[:date]).year
          );
        if @new_category.save
          @user.categories << @new_category
          @entry = Entry.create(user_id: entry_params[:user_id], amount: entry_params[:amount], date: entry_params[:date], notes: entry_params[:notes], category_id: @new_category.id, category_name: @new_category.name, income: @new_category.income, untracked: @new_category.untracked)
          if @entry.save
            render json: {
              username: @user.username,
              id: @user.id,
              categories: @user.current_categories,
              year_view: @user.year_view,
              years: @user.years
            }
          else
            @new_category.destroy
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
        if params[:category_name] != @entry.category_name
          @category = @user.categories.select{ |category| category.name == params[:category_name]}[0]
          params[:category_id] = @category.id
          params[:income] = @category.income
          params[:untracked] = @category.untracked
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
  
  def import
    if logged_in
      begin
        Entry.import(import_params)
        @user = User.find(import_params[:user_id])
        render json: {
          message: "Success! Your data is now in Sum.",
          user: {
            username: @user.username,
            id: @user.id,
            categories: @user.current_categories,
            year_view: @user.year_view,
            years: @user.years
          }
        }
      rescue => e
        render json: {message: e.message}
      end
    else
      render json: {error: 'Token Invalid'}, status: 401
    end
  end

  private

  def entry_params
    params.permit(:user_id, :category_id, :date, :amount, :notes, :category_name, :income, :untracked)
  end

  def category_params
    params.permit(:category_name, :income, :untracked)
  end

  def import_params
    params.permit(:file, :user_id)
  end

end
