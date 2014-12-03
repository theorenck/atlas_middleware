class StatementsController < ApplicationController

  def create
    if @service.execute(@statement)
      render json: @statement, status: 200
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
      params.require(:statement).permit(:sql, :limit, :offset).tap do |whitelisted|
        whitelisted[:params] = params[:statement][:params]
      end
    end
end