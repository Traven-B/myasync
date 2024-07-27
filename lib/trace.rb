module Trace
  @@start = Time.now
  @@trace = false

  def self.trace=(do_debug_message)
    @@trace = do_debug_message
  end

  def self.trace?
    @@trace
  end

  def self.start
    @@start
  end

  def self.reset_start_to_zero
    @@start = Time.now
  end

  def dt(msg = "")
    if Trace.trace?
      this_method_name = caller_locations(1, 1)[0].label.gsub(/^block in /, "")
      delta_t = Time.now - @@start  # this is a float representing seconds
      # %[flags][width][.precision]type
      tdiff = sprintf("%7.03f  :  ", delta_t)
      # extra ` + "\n"` on end fixes ruby 3.x.x not always emmitting a new line and then emitting it later
      puts "#{tdiff}#{sprintf("%10s", this_method_name)} : #{msg}".rstrip + "\n"
    end
  end
end
