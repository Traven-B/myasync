require_relative "trace"
require_relative "local_or_not" # read local_or_not before module_names
require "optparse"

class Parser
  def self.parse(args)
    program_name = File.basename $PROGRAM_NAME
    options = {}
    o = OptionParser.new do |opts|
      opts.banner = ("Usage: #{program_name} [OPTIONS]\n" +
                     "Scrape pages at public libraries' web sites.")

      opts.on("-m", "--mock", "this option mocks everything") do
        options[:mock] = true
      end
      sleep_msg1 = "1 (or 2) \e[1mcomma\e[22m separated numbers specifying"
      sleep_msg2 = "(range of) seconds that mocked requests sleep"
      opts.on("-s", "--sleep-range 2,2.2", Array, sleep_msg1, sleep_msg2) do |sleep_range|
        options[:sleep_range] = sleep_range
      end
      opts.on("-l", "--local", "use server on localhost") do
        options[:local] = true
      end
      opts.on("-t", "--trace", "trace where it's all happening") do
        options[:trace] = true
      end
      opts.on_tail("-h", "--help", "--usage", "Show this message") do
        puts opts
        exit
      end
    end

    begin
      o.parse!(args)
      !(args.empty?) && (raise ExtraArguments.new args)
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument,
           OptionParser::NeedlessArgument, OptionParser::InvalidArgument, ExtraArguments => e
      puts e
      puts o
      exit 1
    end

    Local.local = true if options[:local]
    Trace.trace = true if options[:trace]
    options[:sleep_range] = compute_float_or_range(options[:sleep_range]) if options[:sleep_range]

    @help_string = o.to_s # make help_string available as class method

    options   # at end of def parse(args)
  end

  # Make help_string available as class method. Use when processing stuff a bit
  # elsewhere and want to show help when exiting with an exception.
  class << self
    attr_reader :help_string
  end

  def self.compute_float_or_range(sleep_range)
    start, upper_limit = sleep_range
    begin
      raise "Sleep-range option: see '..' separator is comma error" if start.include?("..")
      start = start.to_f
      result = start # when no upper limit or start and upper are equal
      if upper_limit
        upper_limit = upper_limit.to_f
        test = start <=> upper_limit
        if test == -1
          result = (start..upper_limit)
        elsif test == 1
          raise "Sleep-range option: 1st number > 2nd error"
        end
      end
    rescue StandardError => e
      puts e.message
      exit 1
    end
    result
  end

  class ExtraArguments < Exception # non-option arguments not wanted
    def initialize(remaining_argv)
      super("Extra argument(s): #{remaining_argv}")
    end
  end
end
