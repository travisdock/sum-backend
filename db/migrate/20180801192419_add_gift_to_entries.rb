class AddGiftToEntries < ActiveRecord::Migration[5.2]
  def self.up
    add_column :entries, :gift, :boolean
  end
  def self.down
    remove_column :entries, :gift
  end
end
