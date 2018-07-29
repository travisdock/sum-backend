class EntrySerializer < ActiveModel::Serializer
  attributes :category, :date, :amount, :notes

  def category
    self.object.category.name
  end
end
