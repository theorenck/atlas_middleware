class Statement < Model

  attribute :sql
  attribute :limit
  attribute :offset
  attribute :params
  
  attribute :records
  attribute :fetched
  attribute :columns
  attribute :rows

  validates_presence_of :sql,
    :message => 'No SQL statement is defined'

  validates_format_of :sql, 
    :with => /^[\s|\n|\t|\r]*SELECT\b/i, 
    :multiline => true,
    :message => 'Only SELECT statements are allowed'  

  validates_presence_of :offset, 
    :if => :limit?,
    :message => 'When you define a limit, define also a offset'

  validate :validate_params

  def validate_params
    sql_params = sql.scan(/\s\:(\w+)\b/).uniq.map {|m| m[0]}
    sql_params.each do |sql_param|
      unless params.has_key?(sql_param) and params[sql_param]
        errors.add(:params, "you must define #{sql_param} in your params list")
      end
    end
  end

  def paginated?
     offset and limit
  end

  def sanitize
    sql.gsub!(/(--.*)/,"")
    sql.gsub!(/([\n|\t])/,"\s") 
    sql.gsub!(/\s+/,"\s")
    sql.strip!
  end

  def bind_params
     if params?
      params.each do |key,value|
        sql.gsub!(/(\:#{key})\b/,value.to_s)      
      end
    end
  end

  def prepare
    if valid?
      sanitize
      bind_params
    end
  end

  def to_h
    { 
      statement: {
        records: records,
        fetched: fetched,
        columns: columns,
        rows: rows
      }
    }
  end
end