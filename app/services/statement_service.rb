class StatementService < ODBCService
    
  def execute(statement)
    unless statement.valid?
      return false
    end
    begin
      ODBC::connect(datasource) do |connection|
        statement.prepare
        begin
          if statement.paginated? && defined? ODBC 
            connection.set_option(ODBC::SQL_CURSOR_TYPE, ODBC::SQL_CURSOR_DYNAMIC)
          end
          result = connection.run(statement.sql)      
          statement.columns = get_columns(result)
          statement.rows = fetch(result, statement.limit, statement.offset)
          statement.fetched = statement.rows.length
          statement.records = result.nrows == -1 ? statement.rows.length : result.nrows
        ensure
          result.drop if result
          connection.disconnect if connection
        end
      end
    rescue ODBC::Error => e
      statement.errors.add(:base, e.message.force_encoding(Encoding::UTF_8))
      return false
    end
    true
  end

  private

    def fetch(statement, limit = nil, offset = nil)
      rows = []
      return rows if statement.nrows == 0
      if offset and limit
        ((offset+1)..(offset+limit)).each do |index|
          row = statement.fetch_scroll(ODBC::SQL_FETCH_ABSOLUTE, index)
          rows << translate_row(row) if row
        end
      else
        rows = statement.each.collect { |row| translate_row(row).to_a }
      end
      rows
    end

    def translate_row(row)
      row.each_with_index do |field,i|
        if field.is_a? ODBC::Date
          row[i] = field.to_s
        end 
      end
      row
    end

    def get_columns(statement)
      statement.columns(true).collect do |c| 
        {
          name:c.name.downcase, 
          type:c.type #,
          # table: c.table.downcase,
          # length: c.length,
          # precision: c.precision,
          # scale: c.scale,
          # nullable: c.nullable
        }
      end
    end
end