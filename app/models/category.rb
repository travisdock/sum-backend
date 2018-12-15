class Category < ApplicationRecord
  has_many :entries, dependent: :destroy
  has_many :user_categories
  has_many :users, :through => :user_categories

  validates :name, :presence => true

end
