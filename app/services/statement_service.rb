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
          log_sql(model.sql, time)
          if statement.ncols > 0
            time = Benchmark.measure do
              model.fetch statement
            end
            p "(#{time.real}s)" 
          else
            model.records = statement.nrows
          end
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

    def log_sql(sql,time)
      Rails.logger.info "\n \033[35m\033[1mSQL (#{time.real}s)\033[0m \033[1m#{sql}\033[0m\n" 
    end

end