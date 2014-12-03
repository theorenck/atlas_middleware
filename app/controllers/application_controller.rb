class ApplicationController < ActionController::API
  
  before_action :setup
  
  after_action :teardown

  private

  	def setup; end
    
    def teardown
      GC.start
    end  
end
