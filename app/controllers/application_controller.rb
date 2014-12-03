class ApplicationController < ActionController::API
  
  after_action :teardown

  private
    def teardown
      GC.start
    end  
end
