class ChangeColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :entries, :gift, :untracked
    rename_column :categories, :gift, :untracked
  end
end
