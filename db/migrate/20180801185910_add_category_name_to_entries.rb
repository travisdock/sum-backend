class AddCategoryNameToEntries < ActiveRecord::Migration[5.2]
  def self.up
    add_column :entries, :category_name, :string
  end
  def self.down
    remove_column :entries, :category_name
  end
end
