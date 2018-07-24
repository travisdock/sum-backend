class User < ApplicationRecord
  has_many :user_categories
  has_many :categories, :through => :user_categories
  has_many :entries
  validates :username, :presence => true
  validates :username, :uniqueness => true
  validates :password, :presence => true
  validates :email, :presence => true
  has_secure_password


  # def category_totals(date)
  #   self.categories.map { |category| category =>  }
  # end


  def formatted_month_category
    # Get entries for user for this year
    entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year)
    # Group entries by month
    entries_by_month = entries.group_by{ |entry| entry.date.strftime("%B") }
    # Group month's entries by category
    entries_by_month.transform_values! { |entries| entries.group_by{|e| e.category.name } }
    # Change individual entries into sums by category and month
    entries_by_month.each do |month, categories|
      categories.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    end

    return entries_by_month

  end

  def formatted_totals_averages
    # Get start date for user to calculate averages
    start_date = self.entries.order(:date).first.date.month
    # Get entries for user up to current day for total calculations
    total_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_month)
    # Get entries for user up to last month for average calculations
    average_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_month.last_month)

    average_entries = average_entries.group_by{ |entry| entry.category.name }
    # Group entries by category
    entries_by_category = total_entries.group_by{ |entry| entry.category.name }
    # Tranform individual entries into totals and averages by category
    entries_by_category.transform_values! { |entries|
      # byebug
      average = entries.select{ |entry| entry.date.to_time < Time.new.beginning_of_month}
      { "total" => entries.map(&:amount).inject(0, &:+),
        "average" => average.map(&:amount).inject(0, &:+)/(Time.new.month-start_date)
       }
    }
    # entries.map(&:amount).inject(0, &:+)/(Time.new.month-start_date)
    # entries.where(date: Time.new.beginning_of_year..Time.new.end_of_month)
    # entries.map(&:amount).inject(0, &:+)
    return entries_by_category
  end

end

# entries_by_category = entries.group_by{ |entry| }

# entries_by_month = entries_by_month.map{ |month, entries| {month =>  entries.group_by{|e| e.category.name } } }


# entries_by_month = entries_by_month.map do |months|
#   months.map do |month, categories|
#     { month => categories.map do |category, entries|
#       {category => entries.map(&:amount).inject(0, &:+)}
#     end }
#   end
# end

# strftime("%B")
# {category => Entry.where(user: self, category: Category.find_by(name: category), date: ).pluck(Arel.sql('SUM(amount)')) }
