class StatementsController < ApplicationController

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
      
      params[:statement] = alias_attributes(params[:statement],:parameters)

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