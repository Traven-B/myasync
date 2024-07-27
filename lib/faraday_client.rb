require "faraday"
require "faraday-cookie_jar"
require_relative "my_mock_client"

module FaradayClient
  def self.create(mock_client = nil)
    Faraday.new do |faraday|
      faraday.use :cookie_jar
      faraday.request :url_encoded
      faraday.response :raise_error
      if mock_client
        faraday.adapter MockAdapter, mock_client
      else
        faraday.adapter Faraday.default_adapter
      end
    end
  end

  class MockAdapter < Faraday::Adapter
    def initialize(app, mock_client = nil)
      super(app)
      @mock_client = mock_client || MyMockClient.new(0)
    end

    def call(env)
      url = env[:url].to_s
      method = env[:method]
      body = env[:body]
      headers = env[:request_headers]

      mock_response = case method
        when :post
          @mock_client.post(url, nil, body)
        when :get
          @mock_client.get(url, headers)
        else
          raise "Unsupported method: #{method}"
        end

      env.response = Faraday::Response.new
      env.response.finish(
        status: mock_response.status,
        body: mock_response.body,
        response_headers: mock_response.headers,
      )

      @app.call(env)
    end
  end
end
