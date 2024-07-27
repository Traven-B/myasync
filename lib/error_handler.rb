module ErrorHandler
  def message_and_exit(e)
    msg = case e
      when Faraday::ConnectionFailed
        if e.message.include?("localhost") || e.message.include?("127.0.0.1")
          "Start a server on localhost. Run:\nbundle exec lib/local_server.rb"
        else
          "You are not connected to the internet (or the remote server is unreachable.)"
        end
      else
        "Exiting on unexpected exception"
      end

    puts e.class
    puts e.message
    puts
    puts msg
    exit 1
  end
end
