class ODBCService

  def initialize(datasource = "atlas")
    @datasource = "atlas"
  end
  
  protected

    def datasource
      @datasource
    end

    def connect
      begin
        ODBC::connect(@datasource) do |connection|
          yield connection if block_given?
        end
      rescue ODBC::Error => e
        Rails.logger.info e
        {} 
      end
    end
    
end