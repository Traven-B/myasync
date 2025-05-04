require "async"
require "async/await" # added for async def ... end syntax
require "async/http/faraday"
require "nokogiri"
require "date"
require "uri"
require_relative "recs"
require_relative "module_names"
require_relative "print"
require_relative "redirect_handler"
require_relative "error_handler"

#    module Async
# A task represents the state associated with the execution of an asynchronous
# block.
#      class Task < Node
#          # Retrieve the current result of the task. Will cause the caller to wait until result is available.
#          # @return [Object] the final expression/result of the task's block.
#          def wait
#            Task.yield { @result }
#          end

# Deprecated.
#          alias result wait
# Soon to become attr :result

class Application
  include Async::Await   # added for async def ... end syntax
  include Trace
  include RedirectHandler
  include ErrorHandler

  def initialize(options, internet)
    @options = options
    @internet = internet
  end

  PagePair = Struct.new(:checked_out, :on_hold)

  def start
    Trace.reset_start_to_zero
    result_pages = concurrent_network_part.wait
    parse_and_print(result_pages)
  end

  # def concurrent_network_part
  #   Async do
  #     MODULE_NAMES.map do |a_module|
  #       [fetch_pair(a_module.lib_data), a_module]
  #     end.each { |e| e[0] = e[0].wait }
  #   end
  # end

  async def concurrent_network_part
    the_tasks = MODULE_NAMES.map do |a_module|
      a_task = fetch_pair(a_module.lib_data)
      [a_task, a_module]
    end

    result_pages = the_tasks.map do |task_module_pair|
      fetch_pair_task, a_module = task_module_pair
      fetched_pair_of_pages = fetch_pair_task.wait
      [fetched_pair_of_pages, a_module]
    end
    # result is array of [ <struct PagePair checked_out: String, on_hold: String>, LibraryNameModule ]
    result_pages
  end

  async def fetch_pair(data_param)
    library_name = data_param[:trace_name]
    dt "before post #{library_name}"

    base_url = URI.parse(data_param[:post_url]).tap { |uri| uri.path = "" }.to_s
    conn = @internet.dup.tap { |c| c.url_prefix = base_url }

    begin
      login_response = conn.post(data_param[:post_url]) do |req|
        req.body = data_param[:post_data]
      end
      login_response = follow_redirects(conn, login_response)

      dt " after post #{library_name}"

      checked_out_webpage_task = get_page(conn, data_param[:checked_out_url], "#{library_name} checked out")
      on_hold_webpage_task = get_page(conn, data_param[:holds_url], "#{library_name} on hold")

      checked_out_page = checked_out_webpage_task.wait
      on_hold_page = on_hold_webpage_task.wait
      dt " after both receives for #{library_name}"

      PagePair.new(checked_out_page, on_hold_page)
    rescue => e
      message_and_exit(e)
    end
  end

  async def get_page(conn, the_url, extra)
    dt "before get  #{extra}"
    response = conn.get(the_url)
    response = follow_redirects(conn, response)
    dt " after get  #{extra}"
    response.body
  end

  def parse_and_print(result_pages)
    result_pages.each do |pages_module_pair|
      pages, a_module = pages_module_pair
      checkedout = a_module.parse_checkedout_page(pages.checked_out)
      holds = a_module.parse_on_hold_page(pages.on_hold)
      if !Trace.trace?
        print_name = a_module.lib_data[:print_name]
        Print.print_checked_out_books(checkedout, print_name)
        Print.print_books_on_hold(holds, print_name)
      end
    end
  end
end
