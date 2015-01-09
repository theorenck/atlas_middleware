class ApplicationController < ActionController::API
  
  before_action :setup
  
  after_action :teardown

  private

  	def setup; end
    
    def teardown
      GC.start
    end

    def alias_attributes(params,alias_key)
      if attributes = params[alias_key]
        params["#{alias_key}_attributes"] = attributes
      end
      params.delete alias_key
      params
    end    
end
