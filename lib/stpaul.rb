module StPaul
  STPAUL_BASE_URL_actual = "https://sppl.bibliocommons.com"
  STPAUL_BASE_URL_local = "http://localhost:3000/stpaul"

  STPAUL_BASE_URL = Local.local? ? STPAUL_BASE_URL_local : STPAUL_BASE_URL_actual

  def self.lib_data
    {
      post_data: Secret::POST_DATA,
      post_url: STPAUL_BASE_URL + "/user/login?%2Fuser_dashboard",
      checked_out_url: STPAUL_BASE_URL + "/v2/checkedout",
      holds_url: STPAUL_BASE_URL + "/v2/holds/ready_for_pickup",
      print_name: "St. Paul",
      checked_out_fixture: "s_c_v2.html",
      holds_fixture: "s_h_v2.html",
      trace_name: "StPaul",
    }
  end

  def self.parse_checkedout_page(page)
    stpaul_checked_out_books_page = Nokogiri.parse(page)
    books_out = stpaul_checked_out_books_page.css("div.cp-checked-out-item").map do |book_part|
      the_title = find_title(book_part)
      the_date = find_date(book_part)
      the_renewed_count = find_renewed_count(book_part)
      the_number_waiting = find_number_waiting(book_part)
      CheckedOutRecord.new(the_title, the_date, the_renewed_count, the_number_waiting)
    end
    books_out.sort { |a, b| Recs.checked_compare(a, b) }
  end

  def self.parse_on_hold_page(page)
    stpaul_on_hold_books_page = Nokogiri.parse(page)
    books_on_hold = stpaul_on_hold_books_page.css("div.cp-bib-list-item.cp-hold-item.ready_for_pickup").map do |book_part|
      the_title = find_on_hold_title(book_part)
      the_date = find_on_hold_date(book_part)
      OnHoldRecord.new(the_title, the_date)
    end
    books_on_hold.sort { |a, b| Recs.holds_compare(a, b) }
  end

  def self.find_title(book_part)
    # <a><span class="title-content">Introducing Elixir</span>
    #   <span class="sr-only ">Introducing Elixir, Book</span></a>
    book_part.css("a span.title-content").first.text
  end

  def self.find_date(book_part)
    # <div class="cp-checked-out-due-on">
    #   <span>Due by <span class="cp-short-formatted-date">Nov 19, 2018</span></span></div>
    Date.parse book_part.css("div.cp-checked-out-due-on span.cp-short-formatted-date").first.text
  end

  def self.find_renewed_count(book_part)
    # old <div class="cp-renew-count">
    # old   <span>Renewed</span> <span>1 time</span></div>
    # now
    # <div class="cp-renew-count">Renewed 2 times</div>
    renewed_count_div = book_part.css("div.cp-renew-count").first     # nokogiri element or nil
    if renewed_count_div
      n_times_text = renewed_count_div.text
    else
      n_times_text = "0 times"
    end
    n_times_text.match(/(\d+) times*/)[1].to_i
  end

  def self.find_number_waiting(book_part)
    # old <div class="cp-held-copies-count">
    # old  <span>1 person waiting</span></div>
    # now
    # <div class="cp-held-copies-count">27 people waiting</div>
    number_waiting_div = book_part.css("div.cp-held-copies-count").first   # nokogiri element or nil
    if number_waiting_div
      n_people_waiting_text = number_waiting_div.text
    else
      n_people_waiting_text = "0 people waiting"
    end
    n_people_waiting_text.match(/(?<count_digits>\d+) (?:person|people) waiting/)[:count_digits].to_i
  end

  def self.find_on_hold_title(book_part)
    # <a><span class="title-content">A History of America in Ten Strikes</span>
    #   <span class="sr-only">A History of America in Ten Strikes, Book</span></a>
    book_part.css("a span.title-content").first.text
  end

  def self.find_on_hold_date(book_part)
    # <div class="holds-status ready_for_pickup">
    #   <div class="cp-holds-secondary-info">
    #     <span>Pick up by <span class="cp-short-formatted-date">Nov 14, 2018</span></span></div></div>
    Date.parse book_part.css("div.holds-status.ready_for_pickup span.cp-short-formatted-date").first.text
  end
end
