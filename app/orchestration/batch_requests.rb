class BatchRequests
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if env["PATH_INFO"] == "/api/batch"
      request = Rack::Request.new(env.deep_dup)
      data = JSON.parse(request.body.read, symbolize_names: true)
      responses = data[:requests].map do |override|
        process_request(env.deep_dup, override)
      end
      [200, {"Content-Type" => "application/json"}, [{responses: responses}.to_json]]
    else
      @app.call(env)
    end
  end
  
  def process_request(env, override)
    path, query = override[:url].split("?")
    env["REQUEST_METHOD"] = override[:method]
    env["PATH_INFO"] = path
    env["QUERY_STRING"] = query
    # env["rack.input"] = StringIO.new(override[:body].to_s)
    env["action_dispatch.request.request_parameters"] = override[:body]
    status, headers, body = @app.call(env)
    # body.close if body.respond_to? :close
    # {status: status, headers: headers, body: body.join}
    body.close if body.respond_to? :close
    response_body = ''
    body.each do |b|
      response_body << b
    end
    response = {status: status, headers: headers, body: JSON.parse(response_body)}
    # response.delete(:body) if response[:body].strip.empty?
    response
  end
end

# class BatchRequests

#   DELETED_HEADERS = [
#     "X-Frame-Options",
#     "X-XSS-Protection",
#     "X-Content-Type-Options"
#     # "X-UA-Compatible",
#     # "X-Request-Id",
#     # "X-Runtime",
#     # "Cache-Control",
#     # "ETag"
#   ]

#   def initialize(app)
#     @app = app
#   end

#   def call(env)
#     if env["PATH_INFO"] == "/batch"
#       # request = Rack::Request.new(env.deep_dup)
#       request = JSON.parse(env["rack.input"].gets)
#       responses = request["requests"].map do |override|
#       # responses = JSON.parse(request[:requests]).map do |override|
#         process_request(env.deep_dup, override)
#       end
#       [200, {"Content-Type" => "application/json"}, [{responses: responses}.to_json]]
#     else
#       @app.call(env)
#     end
#   end

#   def process_request(env, override)
#     path, query = override["url"].split("?")
#     env["REQUEST_METHOD"] = override["method"]
#     env["PATH_INFO"] = path
#     env["QUERY_STRING"] = query
#     env["rack.input"] = StringIO.new(override["body"] || "")
#     status, headers, body = @app.call(env)
#     DELETED_HEADERS.each do |header|
#        headers.delete header
#     end
#     body.close if body.respond_to? :close
#     response_body = ''
#     body.each do |b|
#       response_body << b
#     end
#     response_body
#     response = {status: status, headers: headers, body: response_body}
#     response.delete(:body) if response[:body].strip.empty?
#     response
#   end
# end