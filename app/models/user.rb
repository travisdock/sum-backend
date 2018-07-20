class User < ApplicationRecord
  has_many :user_categories
  has_many :categories, :through => :user_categories
  has_many :entries
  has_secure_password


  def get_totals
    entries_by_month = User.first.entries.group_by{ |entry| entry.date.beginning_of_month }
    return entries_by_month.map{ |month, entries| {month =>  entries.group_by{|e| e.category.name } } }
  end

end
