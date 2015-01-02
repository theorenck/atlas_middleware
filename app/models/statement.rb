class Statement < ActiveType::Object
  
  nests_many :parameters

  attribute :sql
  attribute :limit
  attribute :offset
  
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

  validate :validate_parameters

  def validate_parameters
    placeholders = sql.scan(/\s\:(\w+)\b/).uniq.map {|m| m[0]}
    placeholders.each do |placeholder|
      unless parameters.select {|p| p.name == placeholder } != []
        errors.add(:parameters, "you must define #{placeholder} in your parameters list")
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

  def bind
     if parameters?
      parameters.each do |parameter|
        sql.gsub!(/(\:#{parameter.name})\b/,parameter.value.to_s)      
      end
    end
  end

  def prepare
    if valid?
      sanitize
      bind
    end
    logger.info "\n  #{Hash[parameters.collect {|e| [e.name, e.value] }]}" if parameters?
    logger.info "\n  SQL: #{sql}\n"
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