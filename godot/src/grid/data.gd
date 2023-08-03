class_name Data
extends Node

enum Special {
	ROW,
	COL,
	BOMB,
	ULT,
}

signal invalid_swap(pos, dir)
signal swapped(pos, dest)
signal moved(pos, dest)

signal filled(pos, value)
signal created()
signal matched(pos)
signal special_matched(pos, value, type)

signal update()

@export var width := 9
@export var height := 9
@export var min_match := 3
@export var debug := false

var _data: Array = []
var _pieces: Array = []

# Don't touch! Only for testing
func set_data(d):
	_data = d

func create_data(pieces: Array):
	_pieces = pieces.duplicate()
	_create_new_empty()
	refill_data()
	created.emit()

func _create_new_empty():
	_data = []
	_data.resize(height)

	for y in height:
		_data[y] = []
		_data[y].resize(width)

func refill_data():
	for y in height:
		for x in width:
			var loops = 0
			_fill_random(x, y)
			
			while get_matches(x, y).size() > 0 and loops < 100: 
				loops += 1
				_fill_random(x, y)
	_print('Refill')

func _print(msg = ''):
	if debug:
		print('------- %s --------' % msg)
		for x in _data:
			print(x)
		print("---------------------------")

func get_matches(x: int, y: int):
	var piece = get_value(x, y)

	var check = func(pos: Array):
		var row = _create_match_array(pos)
		var filtered = _filter_match_array(row, piece)
		if filtered.size() >= min_match:
			return filtered.map(func(a): return a["pos"])
		return null

	if piece != null:
		if x > 1:
			var row_match = check.call([Vector2i(x, y), Vector2i(x-1, y), Vector2i(x-2, y)])
			if row_match:
				return row_match
		if y > 1:
			var col_match = check.call([Vector2i(x, y), Vector2i(x, y-1), Vector2i(x, y-2)])
			if col_match:
				return col_match

	return []

func _create_match_array(pos: Array):
	var arr = []
	for p in pos:
		arr.append({"value": get_value(p.x, p.y), "pos": p})
	return arr

func _filter_match_array(arr: Array, value: int):
	var filtered = arr.filter(func(a): return a["value"] == value)
	if filtered.size() > 0:
		return filtered
	return []

func get_value(x: int, y: int):
	if x < 0 or x >= width:
		return null
	
	if y < 0 or y >= height:
		return null

	return _data[y][x]

func _set_value(x: int, y: int, value):
	_data[y][x] = value

func _swap_value(p1: Vector2i, p2: Vector2i):
	var temp = get_value(p2.x, p2.y)
	_set_value(p2.x, p2.y, get_value(p1.x, p1.y))
	_set_value(p1.x, p1.y, temp)

func swap(pos: Vector2i, dest: Vector2i):
	var piece = get_value(pos.x, pos.y)
	if piece == null:
		return # Invalid move, no animation needed either

	var other = get_value(dest.x, dest.y)
	if other == null:
		invalid_swap.emit(pos, dest - pos)
		return

	_swap_value(pos, dest)
	swapped.emit(pos, dest)
	_print('Swap')
	if not check_matches(dest):
		_swap_value(dest, pos)
		swapped.emit(dest, pos)

func check_matches(dest: Vector2i = Vector2i(-1, -1)):
	var all_matched = []
	for y in height:
		for x in width:
			var matches = get_matches(x, y)
			if matches.size() > 0:
				for m in matches:
					if not m in all_matched:
						all_matched.append(m)

	var has_matched = all_matched.size() > 0
	if has_matched:
		var special_matches = []
		for i in all_matched:
			if i in special_matches:
				continue
			
			var value = get_value(i.x, i.y)
			var col_matched = []
			var row_matched = []

			for j in all_matched:
				var other_value = get_value(j.x, j.y)
				if value == other_value:
					if j.x == i.x:
						col_matched.append(j)
					if j.y == i.y:
						row_matched.append(j)
			
			var row = row_matched.size()
			var col = col_matched.size()
			if row >= 5 or col >= 5:
				var actual_match = []
				if row >= 5:
					_append_unique(actual_match, [row_matched])
				if col >= 5:
					_append_unique(actual_match, [col_matched])
				
				special_matches.append_array(actual_match)
				_emit_special(actual_match, dest, Special.ULT)
			if row >= 3 and col >= 3:
				var actual_match = []
				_append_unique(actual_match, [col_matched, row_matched])
				special_matches.append_array(actual_match)
				_emit_special(actual_match, dest, Special.BOMB)
			if col == 4:
				special_matches.append_array(col_matched)
				_emit_special(col_matched, dest, Special.COL)
			if row == 4:
				special_matches.append_array(row_matched)
				_emit_special(row_matched, dest, Special.ROW)

		for m in all_matched:
			_set_value(m.x, m.y, null)
		matched.emit(all_matched)
		update.emit()
		
		_print('Match')
		collapse_columns()

	return has_matched

func _append_unique(arr, items: Array):
	for item in items:
		for i in item:
			if not i in arr:
				arr.append(i)

func _emit_special(matches: Array, dest: Vector2i, type: int):
	print(dest in matches)
	print(matches)
	var pos = dest if dest in matches else matches[0]
	var value = get_value(pos.x, pos.y)
	special_matched.emit(pos, value, type)

func collapse_columns(check = true, fill = true):
	for x in width:
		for y in range(height-1, -1, -1):
			if get_value(x, y) == null:
				var yy = _first_non_null_above(x, y)
				if yy == null:
					break;

				_swap_value(Vector2i(x, yy), Vector2i(x, y))
				moved.emit(Vector2i(x, yy), Vector2i(x, y))

	if fill:
		update.emit()
		_print('Collapse')
		fill_empty()

	if check:
		check_matches()

func _first_non_null_above(x: int, y: int):
	for yy in range(y-1, -1, -1):
		if get_value(x, yy) != null:
			return yy
	return null

func fill_empty():
	for x in width:
		for y in range(height-1, -1, -1):
			if get_value(x, y) == null:
				var value = _fill_random(x, y)
				filled.emit(Vector2i(x, y), value)
	
	update.emit()
	_print('Fill')

func _fill_random(x: int, y: int):
	var piece = _pieces.pick_random()
	_set_value(x, y, piece)
	return piece
