class StatementSerializer < ActiveModel::Serializer
  attributes :records, :fetched, :columns, :rows
end
