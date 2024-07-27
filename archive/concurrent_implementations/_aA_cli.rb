require_relative "parser"

module Myasync
  module CLI
    def self.run
      options = Parser.parse(ARGV)
      # give parser chance to fiddle with this and that module it required
      # then have application require most all
      require_relative "application"
      agent = options[:mock] ? MyMockClient.new(options[:sleep_range]) : nil
      Application.new(options, agent).start
    end
  end
end
