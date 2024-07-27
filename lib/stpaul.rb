module StPaul
  STPAUL_BASE_URL_actual = "https://alpha.stpaul.lib.mn.us"
  STPAUL_BASE_URL_local = "http://localhost:3000/stpaul"

  STPAUL_BASE_URL = Local.local? ? STPAUL_BASE_URL_local : STPAUL_BASE_URL_actual

  def self.lib_data
    {
      post_data: Secret::POST_DATA,
      post_url: STPAUL_BASE_URL + "/patroninfo~S16",
      checked_out_url: STPAUL_BASE_URL + "/patroninfo~S16/1600472/items",
      holds_url: STPAUL_BASE_URL + "/patroninfo~S16/1600472/holds",
      print_name: "St. Paul",
      checked_out_fixture: "s_c.html",
      holds_fixture: "s_h.html",
      trace_name: "StPaul",
    }
  end

  def self.parse_checkedout_page(page)
    doc = Nokogiri.parse(page)
    books_out = doc.css("table tr.patFuncEntry").map do |record|
      book_record = CheckedOutRecord.new
      book_record.title = finds_either_title(record)
      td_status = record.css("td.patFuncStatus").first
      status = td_status.text.strip
      date_match = status.match(
        /^.* ([0-9]{2})-([0-9]{2})-([0-9]{2}).*$/
      )
      book_record.due_date = Date.new(
        "20#{date_match[3]}".to_i, date_match[1].to_i, date_match[2].to_i
      )
      # status is word DUE, date, times renewed (what if it's over due? prolly have a date anyway)
      # puts status
      # puts due_date.strftime("%A %B %d, %Y")
      renewed_span = record.css("td.patFuncStatus span.patFuncRenewCount").first
      renewed_count_text = "Renewed 0 times"
      if renewed_span
        renewed_count_text = renewed_span.text.strip
      end
      renewed_count_match = renewed_count_text.match(
        /^Renewed ([0-9]{1}) times*$/ # *s for time or times possibly appearing
      )
      book_record.renewed_count = renewed_count_match[1].to_i
      book_record.number_waiting = 0
      book_record
    end
    books_out.sort { |a, b|
      (a.due_date == b.due_date) ?
        a.title.downcase.sub(/^(the|a|an)\s+/i, "") <=> b.title.downcase.sub(/^(the|a|an)\s+/i, "") :
        a.due_date <=> b.due_date
    }
  end

  def self.parse_on_hold_page(page)
    doc = Nokogiri.parse(page)
    books_on_hold = doc.css("table tr.patFuncEntry").map do |record|
      td_status = record.css("td.patFuncStatus").first
      status = td_status.text.strip
      if status.match(/^Ready/)
        book_record = OnHoldRecord.new
        book_record.title = finds_either_title(record)
        date_match = status.match(
          /^.* ([0-9]{2})-([0-9]{2})-([0-9]{2}).*$/
        )
        book_record.exp_date = Date.new(
          "20#{date_match[3]}".to_i, date_match[1].to_i, date_match[2].to_i
        )
        book_record
      end
    end.compact
    books_on_hold.sort { |a, b|
      (a.exp_date == b.exp_date) ?
        a.title.downcase.sub(/^(the|a|an)\s+/i, "") <=> b.title.downcase.sub(/^(the|a|an)\s+/i, "") :
        a.exp_date <=> b.exp_date
    }
  end

  def self.finds_either_title(book_part)
    # <th class="patFuncBibTitle" scope="row"><a href="/record=b1266537~S16">
    # <span class="patFuncTitleMain">Feed zone portables : a cookbook et cetera / Biju Thomas & Allen Lim.</span></a><br />
    # </th>
    title_span = book_part.css("th.patFuncBibTitle span.patFuncTitleMain").first
    # remove the author after a /  remove possible sub title after a :
    # remove the author after an old style title [by] author sequence
    title = title_span.inner_text.split(" /")[0].split(" :")[0].split(" [by]")[0]
    title = title[0, 42]
    title.sub(/\.$/, "")
  end
end
