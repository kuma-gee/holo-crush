extends UnitTest

func test_create_from_iso_string():
    var dt = DateTime.new('2020-01-01T00:00:00Z')
    assert_eq(dt.get_time(), 1577836800)

func test_get_diff_in_minutes():
    var dt = DateTime.new('2020-01-01T00:10:00')
    assert_eq(dt.get_diff_in_minutes(DateTime.new('2020-01-01T00:20:00')), 10)
    assert_eq(dt.get_diff_in_minutes(DateTime.new('2020-01-01T00:00:00')), -10)