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

  # validates_format_of :sql, 
  #   :with => /^[\s|\n|\t|\r]*SELECT\b/i, 
  #   :multiline => true,
  #   :message => 'Only SELECT statements are allowed'  

  validates_presence_of :limit, 
    :if => :offset?,
    :message => 'When you define a offset, you must first define a limit'

  validate :validate_parameters

  before_validation :set_limit

  after_validation :prepare

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
    fix_time_functions
    sql.strip!
  end

  def bind
     if parameters?
      parameters.each do |parameter|
        sql.gsub!(/(\:#{parameter.name})\b/,parameter.value.to_s)      
      end
    end
  end

  def scroll_indexes
    ((offset+1)..(offset+limit))
  end

  def prepare
    sanitize
    bind
  end

  def to_h
    { 
      result: {
        records: records,
        fetched: fetched,
        columns: columns || [],
        rows: rows || []
      }
    }
  end

  protected

    def fix_time_functions()
      p sql
      fix_curdate
      fix_curtime
      fix_curtimestamp
      p sql
    end

    def fix_curdate()
      sql.gsub!(/(\{\s*fn\s+(?:curdate|current_date)\s*\(\s*\)\s*\})/i,"{D '#{Time.now.strftime '%Y-%m-%d'}'}")
    end

    def fix_curtime()
      sql.gsub!(/(\{\s*fn\s+(?:curtime|current_time)\s*\(\s*\)\s*\})/i,"{T '#{Time.now.strftime '%H:%M:%S'}'}")
    end

    def fix_curtimestamp()
      sql.gsub!(/(\{\s*fn\s+(?:curtimestamp|current_timestamp)\s*\(\s*\)\s*\})/i,"{TS '#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}'}")
    end

    def set_limit
      if limit_clause
        limit = limit_clause.scan(/LIMIT\s+(\d+|all).*/i).try(:first).try(:first)
        if 'ALL'.casecmp(limit) == 0
          self.limit = Float::INFINITY
        else
          self.limit = limit.to_i
        end
        offset = limit_clause.scan(/LIMIT\s+(?:\d+|all)\s+OFFSET\s+(\d+)/i).try(:first).try(:first)
        self.offset = offset.to_i
      end
      sql.gsub!(/\b(LIMIT\b.*)/i,"")
    end

    def limit_clause
      @limit_clause ||= sql.scan(/\b(LIMIT\b.*)/i).try(:first).try(:first)
    end
end