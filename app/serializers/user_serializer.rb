class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :email, :categories, :entries

  def categories
    self.object.categories
  end

  def entries
    self.object.entries
  end
  
end
