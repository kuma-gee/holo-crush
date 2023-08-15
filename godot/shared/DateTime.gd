class_name DateTime

var _time := 0

static func now():
    return DateTime.new(Time.get_unix_time_from_system())

func _init(t):
    if typeof(t) == TYPE_STRING:
        _time = Time.get_unix_time_from_datetime_string(t)
    elif typeof(t) == TYPE_INT:
        _time = t
    elif typeof(t) == TYPE_FLOAT:
        _time = int(t)
    
func get_time():
    return _time

func get_diff_in_minutes(dt: DateTime):
    var diffSec = dt.get_time() - get_time()
    return int(diffSec / 60.0)

func add_minutes(m: int):
    return DateTime.new(_time + m * 60)

func _to_string():
    return Time.get_datetime_string_from_unix_time(_time)