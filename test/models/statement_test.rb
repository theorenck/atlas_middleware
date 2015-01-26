require 'test_helper'

class StatementTest < ActiveSupport::TestCase

  def setup
    @statement = Statement.new(sql:"SELECT * FROM zw14phis", limit:100, offset:0)
    @service = StatementService.new
    @schema_service = SchemaService.new
  end

  test "the truth" do
    #puts JSON.pretty_generate(@schema_service.indexes("zw14ppro"))
    @service.execute(@statement)
    p @statement.errors
    assert true, true
  end
end