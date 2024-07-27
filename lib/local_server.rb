#!/usr/bin/env ruby

require "sinatra"
require_relative "local_or_not" # read local_or_not before module_names
Local.local = true
require_relative "module_names"

set :port, 3000

BASE_DURATIONS = [2.0, 1.82, 2.22]
POST_ADDITIONAL_DELAY = 0.2

configure do
  set :url_mappings, {}
  set :delay_mappings, {}
end

def strip_query_params(url)
  url.split("?").first
end

def setup_url_mappings
  MODULE_NAMES.each_with_index do |library_module, index|
    data = library_module.lib_data
    i = index % BASE_DURATIONS.length
    settings.url_mappings[strip_query_params(data[:post_url])] = "Login #{library_module.name}"
    settings.url_mappings[strip_query_params(data[:checked_out_url])] = data[:checked_out_fixture]
    settings.url_mappings[strip_query_params(data[:holds_url])] = data[:holds_fixture]

    settings.delay_mappings[strip_query_params(data[:post_url])] = BASE_DURATIONS[i] + POST_ADDITIONAL_DELAY
    settings.delay_mappings[strip_query_params(data[:checked_out_url])] = BASE_DURATIONS[i]
    settings.delay_mappings[strip_query_params(data[:holds_url])] = BASE_DURATIONS[i]
  end
end

setup_url_mappings

post "*" do
  handle_request("post")
end

get "*" do
  handle_request("get")
end

def handle_request(verb)
  url = strip_query_params(request.url)

  if settings.url_mappings.key?(url)
    write_sleep_write "#{verb} #{url}", settings.delay_mappings[url]
    if verb == "post"
      settings.url_mappings[url]
    else
      File.read(File.join(__dir__, "..", "mock_data", "html_pages", settings.url_mappings[url]))
    end
  else
    status 404
    "Not found"
  end
end

def write_sleep_write(a_string, a_duration)
  puts "Request received at : #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} for #{a_string}"
  sleep a_duration
  puts "Request fulfilled at: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")} for #{a_string}"
end
