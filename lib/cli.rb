require_relative "parser"
require_relative "faraday_client"

module MyAsync
  module CLI
    def self.run
      options = Parser.parse(ARGV)
      require_relative "application"
      mock_client = options[:mock] ? MyMockClient.new(options[:sleep_range]) : nil
      # faraday_client = create_faraday_client(mock_client)
      faraday_client = FaradayClient.create(mock_client)
      Application.new(options, faraday_client).start
    end
  end
end
