class QueriesController < ApplicationController

  def create
    if @service.execute(@statement)
      render json: JSON.generate(@statement.to_h), status: 200
    else
      render json: {errors: @statement.errors}, status: 422
    end
  end

  private

    def setup
      @service = StatementService.new
      @statement = Statement.new(statement_params)
    end

    def statement_params

      if query = params[:query]
        params[:statement] = query
      end
      params.delete(:query)
      if sql = params[:statement][:statement]
        params[:statement][:sql] = sql
      end
      params[:statement].delete(:statement) 

      params[:statement] = alias_attributes(params[:statement],:parameters)
      
      params[:statement][:parameters_attributes].each.map do |parameter|
        if type = parameter[:datatype]
          parameter[:type] = type
        end
        parameter.delete(:datatype)
      end

      params.require(:statement).permit(
        :sql, 
        :limit, 
        :offset,
        parameters_attributes:[
          :name,
          :type,
          :value,
          :evaluated
        ]
      )
    end
end