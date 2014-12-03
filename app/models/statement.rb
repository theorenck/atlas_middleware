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
		:with => /^\s*SELECT\s.*\s*$/i, 
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
    sql.gsub!(/(--.*)\n/,"")
    # sql.gsub!(/([\n|\t])/,"\s") 
    # sql.gsub!(/\s+/,"\s")
    # sql.strip!
  end

  def bind_params
    params.each do |key,value|
    	sql.gsub!(/(\:#{key})\b/,param[1].to_s)      
    end
  end

  def prepare
  	if valid?
			bind_params
			sanitize
		end
  end

end