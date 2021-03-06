class SchemaService < ODBCService

  def indexes(table)
    connect do |connection|
      begin
        statement = connection.indexes(table)
        indexes = statement.each_hash
        { indexes: indexes.group_by{|h| h["INDEXNAME"]} }
      rescue ODBC::Error => e
        Rails.logger.debug error
        {}
      ensure
        statement.drop if statement
        connection.disconnect if connection
      end
    end
  end

  def types
    connect do |connection|
      begin
        statement = connection.types
        types = statement.each_hash.collect do |t|
          {
            name: t['TYPENAME'],
            type: t['TYPE'],
            precision: t['PRECISION'],
            params: t['PARAMS'],
            nullable: t['NULLABLE'] == 0 ? false : true,
            casesensitive: t['CASESENSITIVE'] == 0 ? false : true
          }
        end
        { types: types }
      rescue ODBC::Error => e
        Rails.logger.debug error
        {}
      ensure
        statement.drop if statement
        connection.disconnect if connection
      end
    end
  end
  
  def tables
    connect do |connection|
      begin
        statement = connection.tables
        tables = statement.each.collect { |t| t[2].downcase }
        {tables: tables}
      rescue ODBC::Error => error
        Rails.logger.debug error
        {}
      ensure
        statement.drop if statement
        connection.disconnect if connection
      end
    end
  end

  def schema
    connect do |connection|
      begin
        tables = {}
        statement = connection.columns("")
        statement.each.map do |c|
          table = c[2].downcase
          tables[table] = [] unless tables[table]
          tables[table] << c[3].downcase
        end
        {schema:{tables: tables }}
      rescue ODBC::Error => error
        Rails.logger.debug error
        return {}
      ensure
        statement.drop if statement
        connection.disconnect if connection
      end
    end
  end

  def table(table)
    connect do |connection|
      begin
        # count = count(connection,table)
        statement = connection.columns(table)
        columns = statement.each_hash.collect do |column|
          {
            name: column['COLUMNNAME'].downcase,
            type: column['TYPE'] # ,
            # table: column['TABLENAME'].downcase,
            # length: column['LENGTH'],
            # precision: column['PRECISION'],
            # scale: column['SACALE'],
            # nullable: column['NULLABLE'] == 0 ? false : true,
            # typename: column['TYPENAME'],
            # position: column['ORDINAL_POSITION']
          }   
        end
        { name: table.downcase, columns: columns }
      rescue ODBC::Error => error
        Rails.logger.debug error
        return {}
      ensure
        statement.drop if statement
        connection.disconnect if connection
      end
    end
  end
end