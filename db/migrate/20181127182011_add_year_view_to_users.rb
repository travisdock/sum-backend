class AddYearViewToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :year_view, :integer, :default => Time.current.year
  end
end
