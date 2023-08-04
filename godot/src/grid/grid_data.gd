class_name GridData

var _data: Array = []
var _logger = Logger.new("GridData")

var width := 0
var height := 0

func _init(w: int, h: int, init_data: Array = []):
	width = w
	height = h
	if init_data.size() == 0:
		_data = _create_new_empty(w, h)
	else:
		_data = init_data

func _create_new_empty(w: int, h: int):
	var data = []
	data.resize(h)

	for y in height:
		data[y] = []
		data[y].resize(w)
	return data

func print_data(msg = ''):
	_logger.debug('------- %s --------' % msg)
	for x in _data:
		_logger.debug(str(x))
	_logger.debug("---------------------------")

func get_value_v(p: Vector2i):
	return get_value(p.x, p.y)

func get_value(x: int, y: int):
	if not _is_inside(x, y):
		return null
	return _data[y][x]

func set_value_v(p: Vector2i, value):
	set_value(p.x, p.y, value)

func set_value(x: int, y: int, value):
	if not _is_inside(x, y):
		_logger.warn("Trying to set invalid position %s/%s to %s" % [x, y, value])
		return

	_data[y][x] = value

func swap_value(p1: Vector2i, p2: Vector2i):
	var temp = get_value(p2.x, p2.y)
	set_value_v(p2, get_value_v(p1))
	set_value_v(p1, temp)

func _is_inside(x: int, y: int):
	if x < 0 or x >= width:
		return false
	
	if y < 0 or y >= height:
		return false

	return true