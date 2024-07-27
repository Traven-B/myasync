CheckedOutRecord = Struct.new(:title, :due_date, :renewed_count, :number_waiting)
OnHoldRecord = Struct.new(:title, :exp_date)

class Recs
  def self.alter_title_key(a_string)
    a_string.downcase.sub(/^(the|a|an)\s+/i, "")
  end

  def self.date_then_title_compare(a_date, b_date, a_title, b_title)
    if a_date != b_date
      a_date <=> b_date
    else
      alter_title_key(a_title) <=> alter_title_key(b_title)
    end
  end

  def self.checked_compare(a, b)
    date_then_title_compare(a.due_date, b.due_date, a.title, b.title)
  end

  def self.holds_compare(a, b)
    date_then_title_compare(a.exp_date, b.exp_date, a.title, b.title)
  end
end
