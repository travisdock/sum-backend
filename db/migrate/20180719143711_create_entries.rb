class CreateEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :entries do |t|
      t.integer :user_id
      t.integer :category_id
      t.date :date
      t.integer :amount
      t.string :notes

      t.timestamps
    end
  end
end
