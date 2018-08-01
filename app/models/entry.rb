class Entry < ApplicationRecord
  require 'csv'
  belongs_to :user
  belongs_to :category

  validates :date, :presence => true
  validates :amount, :presence => true
  validates :amount, :numericality => { :greater_than_or_equal_to => 0 }
  # validates :amount, numericality: { only_integer: true }
  validates :user_id, :presence => true
  validates :category_id, :presence => true

  def self.import
    file = '/Users/flatironschool/Downloads/data.csv'
    CSV.foreach(file, headers: true) do |row|
      data = row.to_hash
      @user = User.find(data["user_id"])
      @category = @user.categories.find_by(name: data["category"])
      data["category"] = @category
      Entry.create(data)
    end
  end
end
