require_relative "test_helper"
require "recs"

class RecsTest < Minitest::Test
  # "a" <=> "b" => -1
  def test_checked_compare_when_dates_differ
    earlier_lesser = CheckedOutRecord.new("z", Time.local(2000, 1, 1), 0, 0)
    later_greater = CheckedOutRecord.new("a", Time.local(2000, 1, 2), 0, 0)
    result = Recs.checked_compare earlier_lesser, later_greater
    assert_equal (-1), result
    result = Recs.checked_compare later_greater, earlier_lesser
    assert_equal 1, result
  end

  def test_checked_compare_when_dates_equal
    lesser = CheckedOutRecord.new("The A", Time.local(2000, 1, 1), 0, 0)
    greater = CheckedOutRecord.new("A Z", Time.local(2000, 1, 1), 0, 0)
    result = Recs.checked_compare lesser, greater
    assert_equal (-1), result
    result = Recs.checked_compare greater, lesser
    assert_equal 1, result
    same = CheckedOutRecord.new("an  A", Time.local(2000, 1, 1), 0, 0)
    as = CheckedOutRecord.new("The a", Time.local(2000, 1, 1), 0, 0)
    result = Recs.checked_compare same, as
    assert_equal 0, result
  end

  def test_holds_compare_when_dates_differ
    earlier_lesser = OnHoldRecord.new("z", Time.local(2000, 1, 1))
    later_greater = OnHoldRecord.new("a", Time.local(2000, 1, 2))
    result = Recs.holds_compare earlier_lesser, later_greater
    assert_equal (-1), result
    result = Recs.holds_compare later_greater, earlier_lesser
    assert_equal 1, result
  end

  def test_holds_compare_when_dates_equal
    lesser = OnHoldRecord.new("The A", Time.local(2000, 1, 1))
    greater = OnHoldRecord.new("A Z", Time.local(2000, 1, 1))
    result = Recs.holds_compare lesser, greater
    assert_equal (-1), result
    result = Recs.holds_compare greater, lesser
    assert_equal 1, result
    same = OnHoldRecord.new("an  A", Time.local(2000, 1, 1))
    as = OnHoldRecord.new("The a", Time.local(2000, 1, 1))
    result = Recs.holds_compare same, as
    assert_equal 0, result
  end
end
