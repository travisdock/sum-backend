class User < ApplicationRecord
  has_many :user_categories
  has_many :categories, :through => :user_categories
  has_many :entries
  validates :username, :presence => true
  validates :username, :uniqueness => true
  validates :password, :presence => true
  validates :email, :presence => true
  has_secure_password

  def charts
    ##################### PIE CHART #############################
    # Get only expense categories
    categories = self.categories.where(income: false)
    # Get entries for user for this year in expense categories
    entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year, category: categories)
    # Group entries by month
    entries_by_month = entries.group_by{ |entry| entry.date.beginning_of_month }
    # Group month's entries by category
    entries_by_month.transform_values! { |entries| entries.group_by{|e| e.category.name } }
    # Change individual entries into sums by category and month
    entries_by_month.each do |month, categories|
      categories.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    end

    # Get entries for year by category
    entries_for_year = entries.group_by{|e| e.category.name }
    # Sum entries for year by category
    entries_for_year.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    # Create object for pie_data
    entries_for_year = entries_for_year.map { |k, v| [k, v] }
    entries_for_year = {entries.first.date.strftime("%Y") => entries_for_year}
    # Add formatted month entries to pie data object
    pie_data = entries_by_month.map {|e| {e.first.strftime("%B") => e[1].map {|k,v| [k,v]} } }
    # Order data by month
    pie_data.sort_by! {|e| Date::MONTHNAMES.index(e.keys[0]) }
    # Add year data
    pie_data.push(entries_for_year)
    # pie_data
    ########################################################

    ################ PROFIT LOSS CHART #####################
    # Get entries for the year
    p_l_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year)
    # Sort entries by month
    month_group = p_l_entries.group_by{ |entry| entry.date.beginning_of_month }
    # Sort months by profit or loss and total them
    month_group.transform_values! { |entries| entries.group_by{|e| e.category.income }.transform_values! { |entries| entries.map(&:amount).inject(0, &:+)} }
    # Find profit or loss
    month_group.transform_values! { |pl| (pl[true] || 0) - (pl[false] || 0) }
    # Convert to array and sort by month
    p_l_by_month_sorted = Array(month_group).sort_by! { |e| e[0] }
    # Create base format for chart
    p_l_formatted = [["x"], ["Profit/Loss"]]
    # Map and push to base format
    p_l_by_month_sorted.map { |arr| p_l_formatted[0].push(arr[0]); p_l_formatted[1].push(arr[1]) }
    # p_l_formatted
    #############################################################

    charts = {
      p_l: p_l_formatted,
      pie_data: pie_data
    }

    return charts

  end

  def profit_loss
    # Get entries for the year
    entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year)
    # Sort entries by month
    month_group = entries.group_by{ |entry| entry.date.beginning_of_month }
    # Sort months by profit or loss and total them
    month_group.transform_values! { |entries| entries.group_by{|e| e.category.income }.transform_values! { |entries| entries.map(&:amount).inject(0, &:+)} }
    # Find profit or loss
    month_group.transform_values! { |pl| (pl[true] || 0) - (pl[false] || 0) }
    # Convert to array and sort by month
    p_l_by_month_sorted = Array(month_group).sort_by! { |e| e[0] }
    # Create base format for chart
    p_l_formatted = [["x"], ["Profit/Loss"]]
    # Map and push to base format
    p_l_by_month_sorted.map { |arr| p_l_formatted[0].push(arr[0]); p_l_formatted[1].push(arr[1]) }

    return p_l_formatted

  end

  def table
    entries = self.entries

    entries = entries.map { |e| {category: e.category.name, date: e.date, amount: e.amount, notes: e.notes}  }

    return entries
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

# def category_totals(date)
#   self.categories.map { |category| category =>  }
# end


  ############BAR CHART INFO###############
# column1 = (entries_by_month.map { |e| e[0] }).unshift("x")
# columns = self.categories.map do |category|
#   entries_by_month.map do |date, totals|
#     totals[category.name]
#   end.map{|e| e ? e : 0 }.unshift(category.name)
# end.unshift(column1)
###########################################

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
