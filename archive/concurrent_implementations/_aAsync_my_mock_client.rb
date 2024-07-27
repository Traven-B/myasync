# mock three methods in Async::HTTP::Internet -- post(), get(), close()

class MyMockClient
  def initialize(range = nil)
    @sleep_range = range || 0.0
    @filename_for = {}
    MODULE_NAMES.each do |m|
      the_params = m.lib_data
      @filename_for[the_params[:checked_out_url]] = the_params[:checked_out_fixture]
      @filename_for[the_params[:holds_url]] = the_params[:holds_fixture]
    end
  end

  def constant_or_random_float
    # rand 2.0 does not yield 2.0, but 1 or 0, rand(2.0..2.0) yields 2.0
    # sleep, Async::Task.current.sleep, something else to suspend?
    @sleep_range.instance_of?(Float) ? @sleep_range : rand(@sleep_range)
  end

  def post(url, _n, post_data) # _n parameter is place holder for a nil we use as a mystery actual argument
    Async::Task.current.sleep(constant_or_random_float)
    # always send same post response
    Protocol::HTTP::Response[200, Protocol::HTTP::Headers["Content-Type" => "text/html"], ["XXXpost page"]]
  end

  def get(url, headers)
    Async::Task.current.sleep(constant_or_random_float)
    # given the get url parameter as key, look up the filename of the web page
    file_name_of_page = @filename_for[url]
    absolute_path = "#{__dir__}/html_pages_for_mocks/#{file_name_of_page}"
    page_string = open(absolute_path) { |io| io.read }
    Protocol::HTTP::Response[200, Protocol::HTTP::Headers["Content-Type" => "text/html"], [page_string]]
  end

  def close
  end
end
