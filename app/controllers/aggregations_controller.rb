class AggregationsController < ApplicationController

  def create
    @executions.each do |execution|
      run(execution)
    end
    if params[:aggregation][:result] 
      @results = eval(params[:aggregation][:result])
    end
    render json: JSON.generate(@results), status: 200
  end

  private

    def execute(parameters)
      source = @sources[parameters["statement"]]
      result = get_statement(source)
      if @service.execute(result)
        @results[parameters["statement"].to_sym] = StatementSerializer.new(result).serializable_hash
      else
        @results[parameters["statement"].to_sym] = result.errors
      end
    end

    def inject(parameters)
      eval("#{parameters['into']} = #{parameters['from']}")
    end

    def get_statement(source)
      statement = {sql: source[:statement]}
      statement[:limit] = source[:limit]
      statement[:offset] = source[:offset]
      statement[:parameters_attributes] = source[:parameters].collect do |p|
        {
          type: p[:datatype], 
          name: p[:name], 
          value: p[:value], 
          evaluated: p[:evaluated]
        }
      end
      Statement.new(statement)
    end

    def run(execution)
      method = execution[:function][:name]
      parameters = {}
      execution[:parameters].each.map do |p|
        parameters[p[:name]] = p[:value]
      end
      if ["execute","inject"].include? method
        send(method, parameters)
      end
    end

    def setup
      @aggregation = params[:aggregation]
      @executions = @aggregation[:executions].sort_by{ |e| e[:order] }
      @sources = Hash[@aggregation[:sources].map { |s| [s[:code], s] }]
      @results = {}
      @service = StatementService.new
    end
end