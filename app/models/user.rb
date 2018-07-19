class User < ApplicationRecord
  has_many :user_categories
  has_many :categories, :through => :user_categories
  has_many :entries
  has_secure_password
end
