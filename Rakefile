require "rake/testtask"

class Rake::Application
  def display_error_message(exception)
    trace "\n#{exception.message}"
    # trace "Tasks: #{exception.chain}" if has_chain?(exception)
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  # t.warning = false
end

task :default => :test
