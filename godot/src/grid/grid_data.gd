class_name GridData

var _data: Array = []
var _logger = Logger.new("GridData")

var min_match := 3
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

func get_match_counts():
	var counts = {}
	for y in height:
		for x in width:
			var matches = get_matches(x, y)
			if matches.size() > 0:
				for m in matches:
					if not m in counts:
						counts[m] = 0
					counts[m] += 1
	return counts


func get_matches(x: int, y: int):
	var piece = get_value(x, y)

	var check = func(pos: Array):
		var row = _create_match_array(pos)
		var filtered = _filter_match_array(row, piece)
		if filtered.size() >= min_match:
			return filtered
		return null

	if piece != null:
		var matches = []
		if x > 1:
			var row_match = check.call([Vector2i(x, y), Vector2i(x-1, y), Vector2i(x-2, y)])
			if row_match:
				for p in row_match:
					if not p in matches:
						matches.append(p)
		if y > 1:
			var col_match = check.call([Vector2i(x, y), Vector2i(x, y-1), Vector2i(x, y-2)])
			if col_match:
				for p in col_match:
					if not p in matches:
						matches.append(p)
		return matches

	return []

func _create_match_array(pos: Array):
	var arr = []
	for p in pos:
		arr.append({"value": get_value(p.x, p.y), "pos": p})
	return arr

func _filter_match_array(arr: Array, value: int):
	var filtered = arr.filter(func(a): return a["value"] == value)
	if filtered.size() > 0:
		return filtered.map(func(a): return a["pos"])
	return []
