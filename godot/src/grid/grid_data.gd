class_name GridData

var _data: Array = []
var _logger = Logger.new("GridData")

# TODO: global variable?
var min_match := 3

var width := 0
var height := 0
var values: Array = []
var _blocked = []

func _init(w: int, h: int, init_data: Array = [], blocked: Array[Vector2i] = []):
	if init_data.size() == 0:
		_data = _create_new_empty(w, h)
	else:
		_data = init_data
		values = []
		for row in init_data:
			for v in row:
				if not v in values and v != null:
					values.append(v)

	width = _data[0].size()
	height = _data.size()
	_blocked = blocked

	for b in blocked:
		_data[b.y][b.x] = null

func get_data():
	return _data.duplicate(true)

func refill(exclude: Array = []):
	for y in height:
		for x in width:
			var pos = Vector2i(x, y)
			if pos in exclude:
				continue

			var loops = 0
			fill_random(x, y)
			
			while get_matches(x, y).size() > 0 and loops < 300: 
				loops += 1
				fill_random(x, y)
	print_data('Refill')

func fill_random(x: int, y: int):
	var val = values.pick_random()
	set_value(x, y, val)
	return val

func _create_new_empty(w: int, h: int):
	var data = []
	data.resize(h)

	for y in h:
		data[y] = []
		data[y].resize(w)
	return data

func duplicate() -> GridData:
	return GridData.new(width, height, _data.duplicate(true))

func print_data(msg = ''):
	_logger.debug('------- %s --------' % msg)
	for x in _data:
		_logger.debug(str(x))
	_logger.debug("---------------------------")

func get_value_v(p: Vector2i):
	return get_value(p.x, p.y)

func get_value(x: int, y: int):
	if not is_inside(x, y):
		return null
	return _data[y][x]

func set_value_v(p: Vector2i, value):
	set_value(p.x, p.y, value)

func set_value(x: int, y: int, value):
	if not is_inside(x, y):
		# _logger.warn("Trying to set invalid position %s/%s to %s" % [x, y, value])
		return

	_data[y][x] = value

func swap_value(p1: Vector2i, p2: Vector2i):
	if not is_inside(p1.x, p1.y) or not is_inside(p2.x, p2.y):
		return

	var temp = get_value_v(p2)
	set_value_v(p2, get_value_v(p1))
	set_value_v(p1, temp)

func is_inside(x: int, y: int):
	if x < 0 or x >= width:
		return false
	
	if y < 0 or y >= height:
		return false
	
	if is_blocked(x, y):
		return false

	return true


func is_blocked(x: int, y: int):
	return Vector2i(x, y) in _blocked

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
					matches.append(p)
		if y > 1:
			var col_match = check.call([Vector2i(x, y), Vector2i(x, y-1), Vector2i(x, y-2)])
			if col_match:
				for p in col_match:
					matches.append(p)
		return matches

	return []

func _create_match_array(pos: Array):
	var arr = []
	for p in pos:
		arr.append({"value": get_value(p.x, p.y), "pos": p})
	return arr

func _filter_match_array(arr: Array, value: int):
	var filtered = arr.filter(func(a): return a["value"] == value) \
		.map(func(a): return a["pos"]) \
		.filter(func(p): return is_inside(p.x, p.y))
	if filtered.size() > 0:
		return filtered
	return []
