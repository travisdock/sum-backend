class EntrySerializer < ActiveModel::Serializer
  attributes :id, :user, :category, :date, :amount, :notes
end
