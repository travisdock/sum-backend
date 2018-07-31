class ChangeAmountColumnToFloat < ActiveRecord::Migration[5.2]
  def self.up
    change_table :entries do |t|
      t.change :amount, :decimal, :precision => 8, :scale => 2
    end
  end
  def self.down
    change_table :entries do |t|
      t.change :amount, :integer
    end
  end
end
