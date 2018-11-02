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

  def self.import(params)
    # @user = User.find(username: params['user'])
    csv_text = File.read(params['file'].tempfile)
    csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
    csv.each do |row|
      data = row.to_hash
      byebug
      @category = @user.categories.select{ |category| category.name == data["category"]}[0]
      Entry.create(data, @user)
    end
  end
end
