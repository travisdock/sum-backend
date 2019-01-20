class ChangeUserDefaultYearViewAgain < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:users, :year_view, { Time.now.year })
  end
end
