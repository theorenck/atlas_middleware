class StatementsController < ApplicationController

  before_action :validate

  def create
    statement = @service.statement(
      params[:statement],
      params[:params],
      params[:limit],
      params[:offset]
    )
    render json: JSON.fast_generate(statement), status: 200
  end

  private

    def validate
      unless params[:statement] and /^select\s.*/ =~ params[:statement].downcase.strip
        render json: {errors: "You need to define a valid SELECT SQL statement" }, status: 422  
      end
    end

    def setup
      @service = StatementsService.new
    end
end