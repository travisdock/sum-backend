class EntrySerializer < ActiveModel::Serializer
  include ActionView::Helpers::NumberHelper
  attributes :id, :category, :date, :amount, :notes

  def category
    self.object.category.name
  end

  # def amount
  #   number_to_currency(self.object.amount)
  # end
end
