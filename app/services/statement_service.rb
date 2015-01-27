class StatementService < ODBCService
    
  def execute(model)
    
    return false unless model.valid?

    begin
      ODBC::connect(datasource) do |connection|
        begin
          statement = connection.newstmt
          if model.paginated? && defined? ODBC 
            statement.set_option(ODBC::SQL_CURSOR_TYPE, ODBC::SQL_CURSOR_DYNAMIC)
          end
          statement.prepare(model.sql)
          time = Benchmark.measure do
            statement.execute
          end
          model.rows = []
          if statement.ncols > 0
            fetch(statement, model)
            model.fetched = model.rows.length
            model.columns = columns(statement)
            model.records = statement.nrows == -1 ? model.rows.length : statement.nrows
          else
            model.records = statement.nrows
          end
          log_sql(model.sql, time)
        ensure
          statement.drop if statement
          connection.disconnect if connection
        end
      end
    rescue ODBC::Error => e
      Rails.logger.info e.message
      model.errors.add(:base, e.message.force_encoding(Encoding::UTF_8))
      return false
    end
    true
  end

  private

    def fetch(statement, model)
      unless statement.nrows == 0
        if model.paginated?
          model.scroll_indexes.each do |index|
            row = statement.fetch_scroll(ODBC::SQL_FETCH_ABSOLUTE, index)
            break unless row
            model.rows << row
          end
        else
          model.rows = statement.fetch_all
        end
      end
      model.rows 
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

    def log_sql(sql,time)
      Rails.logger.info "\n \033[35m\033[1mSQL(#{time.real}s)\033[0m \033[1m#{sql}\033[0m\n" 
    end

end