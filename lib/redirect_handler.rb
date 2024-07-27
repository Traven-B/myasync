module RedirectHandler
  def follow_redirects(conn, response, limit = 5)
    while response.status.between?(300, 399) && limit > 0
      location = response.headers["location"]
      uri = URI(conn.url_prefix)
      new_uri = URI(location)

      unless new_uri.absolute?
        new_uri = uri + new_uri
        location = new_uri.to_s
      end

      response = conn.get(location)
      limit -= 1
    end
    response
  end
end
