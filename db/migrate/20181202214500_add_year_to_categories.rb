class AddYearToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :year, :integer, :default => Time.current.year
  end
end
