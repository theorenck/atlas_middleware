class ODBCService

  def initialize(datasource = "atlas")
    @datasource = "atlas"
  end
  
  protected

    def connect
      begin
        ODBC::connect(@datasource) do |connection|
          yield connection if block_given?
        end
      rescue ODBC::Error => e
        Rails.logger.debug e
        {}
      end
    end

  private
    def count(connection,table)
      begin
        statement = connection.run("SELECT COUNT(*) FROM #{table}")
        statement.first.first
      rescue ODBC::Error => error
        Rails.logger.debug error
        return 0
      ensure
        statement.close if statement
      end
    end
end