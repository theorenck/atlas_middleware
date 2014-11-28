class TypesController < ApplicationController

  def index
    render json: @service.types, status: 200
  end

  private

    def setup
      @service = SchemaService.new
    end
end