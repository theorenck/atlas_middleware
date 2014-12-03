class StatementSerializer < ActiveModel::Serializer
  attributes :records, :fetched, :columns, :rows

  def rows
    object.rows.each_with_index do |row,i|
      row.each_with_index do |field,j|
        if field.is_a? ODBC::Date
          object.rows[i][j] = field.to_s
        end 
      end
    end
  end
end
