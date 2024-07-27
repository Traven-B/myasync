class MyMockClient
  def initialize(range = nil)
    @sleep_range = range || 0.0
    @filename_for = {}
    MODULE_NAMES.each do |m|
      the_params = m.lib_data
      @filename_for[strip_query_params(the_params[:checked_out_url])] = the_params[:checked_out_fixture]
      @filename_for[strip_query_params(the_params[:holds_url])] = the_params[:holds_fixture]
    end
  end

  def constant_or_random_float
    # rand 2.0 does not yield 2.0, but 1 or 0, rand(2.0..2.0) yields 2.0
    # sleep, Async::Task.current.sleep, something else to suspend?
    @sleep_range.instance_of?(Float) ? @sleep_range : rand(@sleep_range)
  end

  def post(url, _headers, body)
    Async::Task.current.sleep(constant_or_random_float)
    # Always send same post response
    MockResponse.new(200, { "Content-Type" => "text/html" }, "XXXpost page")
  end

  def get(url, headers)
    Async::Task.current.sleep(constant_or_random_float)
    # original_url = url
    url_without_params = strip_query_params(url)

    file_name_of_page = @filename_for[url_without_params]

    absolute_path = File.join(__dir__, "..", "mock_data", "html_pages", file_name_of_page)

    if file_name_of_page && File.exist?(absolute_path)
      page_string = File.read(absolute_path)
      MockResponse.new(200, { "Content-Type" => "text/html" }, page_string)
    else
      MockResponse.new(404, { "Content-Type" => "text/plain" }, "Not Found")
    end
  end

  def strip_query_params(url)
    url.split("?").first
  end
end

class MockResponse
  attr_reader :status, :headers, :body

  def initialize(status, headers, body)
    @status = status
    @headers = headers
    @body = body
  end

  def success?
    @status.between?(200, 299)
  end
end
