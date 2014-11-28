class TablesController < ApplicationController

  def index
    render json: @service.tables, status: 200
  end

  def show
    render json: @service.table(params[:id]), status: 200
  end

  private

    def setup
      @service = SchemaService.new
    end
end
