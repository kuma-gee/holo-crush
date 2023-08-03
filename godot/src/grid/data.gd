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
signal special_matched(pos, affected, type)
signal special_activate(pos)

signal update()

@export var width := 9
@export var height := 9
@export var min_match := 3

var _data: Array = []
var _specials = {}
var _pieces: Array = []
var _logger = Logger.new("Data")

# Don't touch! Only for testing
func set_data(d):
	_data = d

func create_data(pieces: Array):
	_pieces = pieces.duplicate()
	_data = _create_new_empty()
	_specials = {}
	refill_data()
	created.emit()

func _create_new_empty():
	var data = []
	data.resize(height)

	for y in height:
		data[y] = []
		data[y].resize(width)
	return data

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
	_logger.debug('------- %s --------' % msg)
	for x in _data:
		_logger.debug(str(x))
	_logger.debug("---------------------------")

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
				_append_unique(matches, [row_match])
		if y > 1:
			var col_match = check.call([Vector2i(x, y), Vector2i(x, y-1), Vector2i(x, y-2)])
			if col_match:
				_append_unique(matches, [col_match])
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

func get_value(x: int, y: int):
	if not _is_inside(x, y):
		return null
	return _data[y][x]

func _set_value(x: int, y: int, value):
	if not _is_inside(x, y):
		_logger.warn("Trying to set invalid position %s/%s to %s" % [x, y, value])
		return

	_data[y][x] = value

func _is_inside(x: int, y: int):
	if x < 0 or x >= width:
		return false
	
	if y < 0 or y >= height:
		return false

	return true

func _swap_special(pos: Vector2i, target: Vector2i):
	var v1 = _specials[pos] if pos in _specials else null
	var v2 = _specials[target] if target in _specials else null

	_specials.erase(pos)
	_specials.erase(target)

	if v1 != null:
		_specials[target] = v1
	if v2 != null:
		_specials[pos] = v2

func _swap_value(p1: Vector2i, p2: Vector2i):
	var temp = get_value(p2.x, p2.y)
	_set_value(p2.x, p2.y, get_value(p1.x, p1.y))
	_set_value(p1.x, p1.y, temp)
	_swap_special(p1, p2)

func swap(pos: Vector2i, dest: Vector2i):
	var value = get_value(pos.x, pos.y)
	if value == null:
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
	var counts = {}
	for y in height:
		for x in width:
			var matches = get_matches(x, y)
			if matches.size() > 0:
				for m in matches:
					if not m in counts:
						counts[m] = 0
					counts[m] += 1


	var has_matched = counts.size() > 0
	if has_matched:
		var all_matched = counts.keys()
		all_matched.sort_custom(func(a, b): return counts[a] > counts[b])

		var special_matches = []
		var remove_special = []

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
			var actual_match: Array
			var type: Special

			if row >= 5 or col >= 5:
				if row >= min_match:
					_append_unique(actual_match, [row_matched])
				if col >= min_match:
					_append_unique(actual_match, [col_matched])
				
				type = Special.ULT
			elif row >= 3 and col >= 3:
				_append_unique(actual_match, [col_matched, row_matched])
				type = Special.BOMB
			elif col == 4:
				actual_match = col_matched
				type = Special.ROW
			elif row == 4:
				actual_match = row_matched
				type = Special.COL

			if actual_match != null and type != null:
				if actual_match.size() > 0:
					special_matches.append_array(actual_match)
					var remove = _create_special(actual_match, dest, type)
					for p in remove:
						if not p in remove_special:
							remove_special.append(p)

		var remove_matched = []
		for m in all_matched:
			if m in special_matches:
				if m in remove_special:
					_remove_value(m)
			else:
				_remove_value(m)
				remove_matched.append(m)
		
		matched.emit(remove_matched)
		update.emit()
		
		_print('Match')
		collapse_columns()

	return has_matched

func _remove_value(p: Vector2i):
	var removed = [p]
	_set_value(p.x, p.y, null)

	if p in _specials:
		var special_pos = _activate_special(p, _specials[p])
		print(special_pos)
		_specials.erase(p)
		for sp in special_pos:
			if sp != p:
				_append_unique(removed, _remove_value(sp))
	return removed

func _activate_special(p: Vector2i, type: Special):
	special_activate.emit(p)
	match type:
		Special.ROW: return _get_row(p)
		Special.COL: return _get_col(p)
	
	return []


func _get_row(p: Vector2i):
	var result = []
	for x in width:
		result.append(Vector2i(x, p.y))
	return result


func _get_col(p: Vector2i):
	var result = []
	for y in height:
		result.append(Vector2i(p.x, y))
	return result


func _append_unique(arr, items: Array):
	for item in items:
		for i in item:
			if not i in arr:
				arr.append(i)

func _create_special(matches: Array, dest: Vector2i, type: int):
	var pos = dest if dest in matches else matches[0]
	_specials[pos] = type 

	var remove = []
	for m in matches:
		if m != pos:
			remove.append(m)

	special_matched.emit(pos, matches, type)
	return remove

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
