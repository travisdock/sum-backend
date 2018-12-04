class User < ApplicationRecord
  has_many :user_categories
  has_many :categories, :through => :user_categories
  has_many :entries
  validates :username, :presence => true
  validates :username, :uniqueness => true
  validates :password, :presence => true, on: :create
  validates :email, :presence => true
  has_secure_password
  
  def years
    return self.entries.map{|entry| entry.date.year}.uniq.sort
  end

  def current_categories
    return self.categories.where(year: self.year_view)
  end
  
  def charts
    year_range = DateTime.new(self.year_view).beginning_of_year..DateTime.new(self.year_view).end_of_year
    if self.entries.where(date: year_range).length == 0
      error = {error: "No Expenses"}
      return error
    end
    
    ################## USEFUL THINGS #############################
    if self.year_view == Date.current.year
      last_month_range = DateTime.new(self.year_view).beginning_of_year..Date.current.last_month.end_of_month
    elsif self.year_view < Date.current.year
      last_month_range = DateTime.new(self.year_view).beginning_of_year..DateTime.new(self.year_view).end_of_year
    elsif self.year_view > Date.current.year
      last_month_range = DateTime.new(self.year_view).beginning_of_year..DateTime.new(self.year_view).end_of_year
    end

    # EXPENSE ENTRIES
    expense_entries = self.entries.where(date: year_range, untracked: false, income: false)
    # EXPENSE ENTRIES UP TO LAST MONTH
    monthly_avg_exp_entries = self.entries.where(date: last_month_range, untracked: false, income: false)

    # INCOME ENTRIES
    income_entries = self.entries.where(date: year_range, income: true)
    # INCOME CATEGORIES UP TO LAST MONTH
    monthly_avg_inc_entries = self.entries.where(date: last_month_range, income: true)
    
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
    # Total Expenses up to Last Month
    monthly_expense_total = monthly_avg_exp_entries.inject(0){|sum,e| sum + e.amount }
    # Total Income up to Last Month
    monthly_income_total = monthly_avg_inc_entries.inject(0){|sum,e| sum + e.amount }


    # Average Total Expense Per Month (calcuated as "per 30 days")
    # Get users input age in days to calculate averages
    start_date = expense_entries.order(:date).first.date
    # end_date = expense_entries.order(:date).last.date
    if self.year_view == Date.current.year
      total_days = (Date.today - start_date).to_i
    elsif self.year_view < Date.current.year
      total_days = (DateTime.new(self.year_view).end_of_year - start_date).to_i
    elsif self.year_view > Date.current.year
      total_days = 0
    end
    months = (total_days / 30).floor

    #if user is less than two months old return string
    if total_days < 60
      avg_exp_per_month = "not enough data"
    else
      avg_exp_per_month = monthly_expense_total / months
    end
    
    # Average Total Income Per Month (calcuated as "per 30 days")
    #if user is less than two months old return string
    if total_days < 60
      avg_inc_per_month = "not enough data"
    else
      avg_inc_per_month = monthly_income_total / months
    end

    # Total Profit - Loss
    annual_p_l = total_income - total_expense

    # Estimated Annual Income
    if total_days < 60
      est_annual_inc = "not enough data"
    else
      est_annual_inc = avg_inc_per_month * 12
    end
    
    # Estimated Annual Expense
    if total_days < 60
      est_annual_exp = "not enough data"
    else
      est_annual_exp = avg_exp_per_month * 12
    end

    # Average Expense per Month by Category
    # Get entries for year by category
    entries_by_category = monthly_avg_exp_entries.group_by{|e| e.category_name }
    # Sum entries for year by category
    entries_by_category.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    # Divide sums by months variable from earlier
    avg_cat_month = entries_by_category.transform_values! { |sum| total_days < 60 ? "not enough data" : sum / months }

    stats = {
      self.year_view => {
        "Total Income" => total_income,
        "Total Expenses" => total_expense,
        "Average Expense per Month" => avg_exp_per_month,
        "Average Income per Month" => avg_inc_per_month,
        "Annual Profit/Loss" => annual_p_l,
        "Estimated Annual Income" => est_annual_inc,
        "Estimated Annual Expense" => est_annual_exp,
        "avg_cat_month" => avg_cat_month
      }
    }

    #############################################################

    ################MONTH STATS#################################
    
    # Totals By Category By Month
    # Group entries by month
    monthly_stats = self.entries.where(date: year_range).group_by{ |entry| entry.date.beginning_of_month.strftime("%B") }
    # Group month's entries by category
    monthly_stats.transform_values! { |entries| entries.group_by{|e| e.category_name } }
    # Change individual entries into sums by category and month
    monthly_stats.each do |month, categories|
      categories.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }
    end

    # Total Income by Month
    income_by_month = income_entries.group_by{ |entry| entry.date.beginning_of_month.strftime("%B") }
    income_by_month.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }

    # Total Expense by Month
    expense_by_month = expense_entries.group_by{ |entry| entry.date.beginning_of_month.strftime("%B") }
    expense_by_month.transform_values! { |entries| entries.map(&:amount).inject(0, &:+) }

    # Place income and expense info into month category hash, then create p&l
    monthly_stats.each do |month, info|
      monthly_stats[month]["Total Income"] = income_by_month[month] || 0
      monthly_stats[month]["Total Expense"] = expense_by_month[month] || 0
      monthly_stats[month]["Profit/Loss"] = monthly_stats[month]["Total Income"] - monthly_stats[month]["Total Expense"]
    end

    # Add to stats
    monthly_stats.each do |month, info|
      stats[month] = monthly_stats[month]
    end

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
