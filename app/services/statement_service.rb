class StatementService < ODBCService
    
  def execute(model)
    
    return false unless model.valid?

    begin
      ODBC::connect(datasource) do |connection|
        begin
          statement = connection.newstmt
          if model.paginated? && defined?(ODBC) && model.offset != 0
            statement.set_option(ODBC::SQL_CURSOR_TYPE, ODBC::SQL_CURSOR_STATIC)
          end
          statement.prepare(model.sql)
          time = Benchmark.measure do
            statement.execute
          end
          puts "(#{time.real}s)"
          if statement.ncols > 0
            fetch_time = Benchmark.measure do
              fetch(statement, model)
            end
            puts "(#{fetch_time.real}s)"
            model.fetched = model.rows.length
            model.columns = columns(statement)
            model.records = statement.nrows == -1 ? model.rows.length : statement.nrows
          end
          model.records = statement.nrows
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
      model.rows = []
      unless statement.nrows == 0
        if model.paginated?
          # (0..model.offset).each do
          #   statement.fetch
          # end
          if model.offset > 0
            statement.fetch_scroll(ODBC::SQL_FETCH_ABSOLUTE, model.offset)
          end
          model.rows = model.limit > 0 ? statement.fetch_many(model.limit) : statement.fetch_all
         # (2..102).each do |index|
         #    row = statement.fetch_scroll(ODBC::SQL_FETCH_RELATIVE,index)
         #    break unless row
         #    model.rows << row
         #  end
        else
          model.rows = statement.fetch_all || []
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