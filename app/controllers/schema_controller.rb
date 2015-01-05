class SchemaController < ApplicationController

  def index
    render json: @service.schema, status: 200
  end

  private

    def setup
      @service = SchemaService.new
    end

end
