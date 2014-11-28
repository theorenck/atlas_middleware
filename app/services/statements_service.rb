class StatementsService < ODBCService

  def statement(sql, params = {}, limit = nil, offset = nil)
    sanitized_sql = sanitize(sql)
    connect do |connection|
      begin 
        connection.set_option(ODBC::SQL_CURSOR_TYPE, ODBC::SQL_CURSOR_DYNAMIC) if offset
        statement = connection.run(sanitized_sql)
        Rails.logger.debug sanitized_sql
        columns = columns(statement)
        rows = fetch(statement, limit, offset)
        { records: statement.nrows, fetched: rows.length, columns: columns, rows: rows }
      rescue ODBC::Error => e
        Rails.logger.debug e
        { errors: utf8(e.message) }
      ensure
        statement.close if statement
        connection.disconnect if connection
      end
    end
  end

  private

    def sanitize(sql)
      sql.gsub(/(--.*)\n/,"").gsub(/([\n|\t])/,"\s").gsub(/\s+/,"\s").strip
    end

    def fetch(statement, limit = nil, offset = nil)
      rows = []
      return rows if statement.nrows == 0
      if offset and limit
        ((offset+1)..((offset+limit))).each do |n|
          row = statement.fetch_scroll(ODBC::SQL_FETCH_ABSOLUTE, n)
          rows << row if row
        end
      elsif offset and limit.nil?
        rows << statement.fetch_scroll(ODBC::SQL_FETCH_ABSOLUTE, offset+1)
        statement.fetch_all.each { |row| rows << row.to_a if row }
      else
        rows = statement.each.collect { |row| row.to_a }
      end
      rows
    end

    def columns(statement)
      statement.columns(true).collect do |c| 
        {
          name:c.name.downcase, 
          type:c.type,
          table: c.table.downcase,
          length: c.length,
          precision: c.precision,
          scale: c.scale,
          nullable: c.nullable
        }
      end
    end

    def utf8(string)
      string.force_encoding(Encoding::UTF_8)
    end
end