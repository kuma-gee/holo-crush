class_name Data
extends Node

signal failed_move(pos, dir)
signal moved(pos, dest)
signal created()
signal matched(pos)

@export var width := 9
@export var height := 9
@export var min_match := 3

var _data: Array[Array] = []

# Don't touch! Only for testing
func set_data(d: Array[Array]):
	_data = d

func create_data(pieces: Array):
	_data = []
	_data.resize(height)

	for y in height:
		_data[y] = []
		_data[y].resize(width)

		for x in width:
			var piece = pieces.pick_random()
			var loops = 0
			_set_value(x, y, piece)
			
			while get_matches(x, y).size() > 0 and loops < 100: 
				piece = pieces.pick_random()
				loops += 1
				_set_value(x, y, piece)

	for x in _data:
		print(x)
	created.emit()

func get_matches(x: int, y: int):
	var piece = get_value(x, y)
	if piece != null:
		if x > 1:
			var row = _create_match_array([Vector2i(x, y), Vector2i(x-1, y), Vector2i(x-2, y)])
			var filtered = _filter_match_array(row, piece)
			if filtered.size() >= min_match:
				return filtered
		if y > 1:
			var col = _create_match_array([Vector2i(x, y), Vector2i(x, y-1), Vector2i(x, y-2)])
			var filtered = _filter_match_array(col, piece)
			if filtered.size() >= min_match:
				return filtered

	return []

func _create_match_array(pos: Array[Vector2i]):
	var arr = []
	for p in pos:
		arr.append({"value": get_value(p.x, p.y), "pos": p})
	return arr

func _filter_match_array(arr: Array, value: int):
	var filtered = arr.filter(func(a): return a["value"] == value)
	if filtered.size() > 0:
		return filtered.map(func(a): return a["pos"])
	return []

func get_value(x: int, y: int):
	if x < 0 or x >= width:
		return null
	
	if y < 0 or y >= height:
		return null

	return _data[y][x]

func _set_value(x: int, y: int, value):
	_data[y][x] = value

func _swap_value(p1: Vector2, p2: Vector2):
	var temp = get_value(p2.x, p2.y)
	_set_value(p2.x, p2.y, get_value(p1.x, p1.y))
	_set_value(p1.x, p1.y, temp)
	moved.emit(p1, p2)

func move(pos: Vector2i, dest: Vector2i):
	var piece = get_value(pos.x, pos.y)
	if piece == null:
		return # Invalid move, no animation needed either

	var other = get_value(dest.x, dest.y)
	if other == null:
		failed_move.emit(pos, dest - pos)
		return

	_swap_value(pos, dest)
	_check_matches()
	
	print("------------------------")
	for x in _data:
		print(x)

func _check_matches():
	for y in height:
		for x in width:
			var matches = get_matches(x, y)
			if matches.size() > 0:
				for m in matches:
					_set_value(m.x, m.y, null)
				matched.emit(matches)

func collapse_columns():
	for y in height:
		for x in width:
			if get_value(x, y) == null:
				for yy in range(y-1, -1, -1):
					if get_value(x, yy) != null:
						_swap_value(Vector2(x, yy), Vector2(x, y))
						break
