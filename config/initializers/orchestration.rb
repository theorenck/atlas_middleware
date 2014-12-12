# Rack Middleware Configuration
Rails.application.config.middleware.insert_after ActionDispatch::ParamsParser, BatchRequests
