class AddIncomeToEntries < ActiveRecord::Migration[5.2]
  def self.up
    add_column :entries, :income, :boolean
  end
  def self.down
    remove_column :entries, :income
  end
end
