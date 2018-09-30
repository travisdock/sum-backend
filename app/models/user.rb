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
    if self.entries.length == 0
      error = {error: "No Entries"}
      return error
    end

    ################## USEFUL THINGS #############################
    # EXPENSE CATEGORIES
    expense_categories = self.categories.where(income: false)
    # EXPENSE ENTRIES
    expense_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year, category: expense_categories)

    # INCOME CATEGORIES
    income_categories = self.categories.where(income: true)
    # INCOME ENTRIES
    income_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year, category: income_categories)

    ##################### PIE CHART #############################
    # If no expenses return error of no expenses so that frontend doesn't break
    if expense_entries.length == 0
      error = {error: "No Expenses"}
      return error
    end

    # MONTHLY CHARTS
    # Group entries by month
    entries_by_month = expense_entries.group_by{ |entry| entry.date.beginning_of_month }
    # Group month's entries by category
    entries_by_month.transform_values! { |entries| entries.group_by{|e| e.category_name } }
    # Change individual entries into sums by category and month
    entries_by_month.each do |month, categories|
      categories.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    end

    # ANNUAL CHART
    # Get entries for year by category
    entries_for_year = expense_entries.group_by{|e| e.category_name }
    # Sum entries for year by category
    entries_for_year.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    # Create object for charts array
    entries_for_year = entries_for_year.map { |k, v| [k, v] }
    entries_for_year = {expense_entries.first.date.strftime("%Y") => entries_for_year}

    # Add formatted month entries to charts array
    charts = entries_by_month.map {|e| {e.first.strftime("%B") => e[1].map {|k,v| [k,v]} } }
    # Order data by month
    charts.sort_by! {|e| Date::MONTHNAMES.index(e.keys[0]) }
    # Add year data
    charts.push(entries_for_year)


    ###############ANNUAL STATS##################################

    # Total Income
    total_income = income_entries.inject(0){|sum,e| sum + e.amount }
    # Total Expense
    total_expense = expense_entries.inject(0){|sum,e| sum + e.amount }

    # Average Total Expense Per Month (calcuated as "per 30 days")
    # Get users input age in days to calculate averages
    start_date = expense_entries.order(:date).first.date
    total_days = (Date.today - start_date).to_i
    months = total_days / 30

    #if user is less than two months old return string
    if total_days < 60
      avg_exp_per_month = "not enough data"
    else
      avg_exp_per_month = total_expense / months
    end
    
    # Average Total Income Per Month (calcuated as "per 30 days")
    #if user is less than two months old return string
    if total_days < 60
      avg_inc_per_month = "not enough data"
    else
      avg_inc_per_month = total_income / months
    end

    # Total Profit - Loss
    annual_p_l = total_income - total_expense

    # Estimated Annual Income
    est_annual_inc = avg_inc_per_month * 12
    # Estimated Annual Expense
    est_annual_exp = avg_exp_per_month * 12

    # Average Expense per Month by Category
    # Get entries for year by category
    entries_by_category = self.entries.group_by{|e| e.category_name }
    # Sum entries for year by category
    entries_by_category.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    # Divide sums by months variable from earlier
    avg_cat_month = entries_by_category.transform_values! { |sum| sum / months}

    stats = {
      "total_income" => total_income,
      "total_expense" => total_expense,
      "avg_exp_per_month" => avg_exp_per_month,
      "avg_inc_per_month" => avg_inc_per_month,
      "annual_p_l" => annual_p_l,
      "est_annual_inc" => est_annual_inc,
      "est_annual_exp" => est_annual_exp,
      "avg_cat_month" => avg_cat_month
    }

    #############################################################

    ################MONTH STATS#################################



    ############################################################

    ################ FORMAT AND RETURN #########################
    charts_hash = Hash.new

    # Turn charts array into hash for easier use on frontend
    charts.each do |chart|
      key = chart.keys.first
      charts_hash[key] = chart[key]
    end

    payload = {
      "charts" => charts_hash,
      "stats" => stats
    }
    # Return hash
    return payload
  end

end


################ PROFIT LOSS CHART #####################
# Get entries for the year
# p_l_entries = self.entries.where(date: Time.new.beginning_of_year..Time.new.end_of_year)
# Sort entries by month
# month_group = p_l_entries.group_by{ |entry| entry.date.beginning_of_month }
# Sort months by profit or loss and total them
# month_group.transform_values! { |entries| entries.group_by{|e| e.income }.transform_values! { |entries| entries.map(&:amount).inject(0, &:+)} }
# Find profit or loss
# month_group.transform_values! { |pl| (pl[true] || 0) - (pl[false] || 0) }
# Convert to array and sort by month
# p_l_by_month_sorted = Array(month_group).sort_by! { |e| e[0] }
# Create base format for chart
# p_l_formatted = [["x"], ["Profit/Loss"]]
# Map and push to base format
# p_l_by_month_sorted.map { |arr| p_l_formatted[0].push(arr[0]); p_l_formatted[1].push(arr[1]) }
# p_l_formatted
#############################################################

def formatted_totals_averages
  if self.entries.length == 0
    error = {error: "No entries"}
    return error
  end
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
