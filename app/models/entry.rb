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
    csv_text = File.read(Rails.root.join('public', 'data.csv'))
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    csv.each do |row|
      byebug
      data = row.to_hash
      @user = User.find(data["user_id"])
      @category = @user.categories.find_by(name: data["category_name"])
      data["category"] = @category
      unless @category.nil?
        data["income"] = @category.income
        data["gift"] = @category.gift
        Entry.create(data)
      end
    end
  end
end
