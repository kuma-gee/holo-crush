class_name MatchGrid
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
signal special_matched(pos, affected, type, value)
signal special_activate(pos)

signal update()

@export var width := 9
@export var height := 9
@export var min_match := 3
@export var debug := false

var _data: GridData
var _specials = {}
var _pieces: Array = []

# Don't touch! Only for testing
func set_data(d):
	_data = d
func get_data():
	return _data._data

func create_data(pieces: Array):
	_pieces = pieces.duplicate()
	_data = GridData.new(width, height)
	_specials = {}
	refill_data()
	created.emit()

func refill_data():
	for y in height:
		for x in width:
			var loops = 0
			_fill_random(x, y)
			
			while get_matches(x, y).size() > 0 and loops < 100: 
				loops += 1
				_fill_random(x, y)
	_data.print_data('Refill')

func is_deadlocked():
	return false

func get_matches(x: int, y: int, data: = _data):
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
	return _data.get_value(x, y)

func _swap_special(pos: Vector2i, target: Vector2i):
	var v1 = _specials[pos] if pos in _specials else null
	var v2 = _specials[target] if target in _specials else null

	_specials.erase(pos)
	_specials.erase(target)

	if v1 != null:
		_specials[target] = v1
	if v2 != null:
		_specials[pos] = v2

func _swap_value_with_special(p1: Vector2i, p2: Vector2i):
	_data.swap_value(p1, p2)
	_swap_special(p1, p2)

func swap(pos: Vector2i, dest: Vector2i):
	var value = get_value(pos.x, pos.y)
	if value == null:
		return # Invalid move, no animation needed either

	var other = get_value(dest.x, dest.y)
	if other == null:
		invalid_swap.emit(pos, dest - pos)
		return

	_swap_value_with_special(pos, dest)
	swapped.emit(pos, dest)
	if not check_matches(dest):
		if not debug:
			_swap_value_with_special(dest, pos)
			swapped.emit(dest, pos)
	else:
		_data.print_data('Swap')

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

		var result = _get_special_match_data(all_matched, dest)
		var special_matches = result[0]
		var create_specials = result[1]

		var remove_matched = []
		for m in all_matched:
			if m in special_matches:
				for l in _remove_value(m):
					var created_special_destroyed_by_other = l in create_specials and l != m
					if not l in remove_matched and (not l in special_matches or created_special_destroyed_by_other):
						remove_matched.append(l)
			else: # All others
				_append_unique(remove_matched, [_remove_value(m)])
		
		for special in create_specials:
			var pair = create_specials[special]
			var type = pair[0]
			var value = pair[1]

			_data.set_value_v(special, value)
			_specials[special] = type
			if special in remove_matched: # Can be immediately removed by another special activation
				for l in _remove_value(special):
					if not l in remove_matched:
						remove_matched.append(l)
		
		matched.emit(remove_matched)
		update.emit()
		
		_data.print_data('Match')
		collapse_columns()

	return has_matched

func _get_special_match_data(all_matched: Array, dest: Vector2i):
	var special_matches = []
	var created_specials = {}

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
				_append_unique(special_matches, [actual_match])
				var special_pos = _create_special(actual_match, dest, type)
				created_specials[special_pos] = [type, get_value(special_pos.x, special_pos.y)]

	return [special_matches, created_specials]

func _create_special(matches: Array, dest: Vector2i, type: int):
	var pos = dest if dest in matches else matches[0]
	special_matched.emit(pos, matches, type, get_value(pos.x, pos.y))
	return pos


func _remove_value(p: Vector2i):
	var removed = [p]
	_data.set_value_v(p, null)

	if p in _specials:
		var special_pos = _activate_special(p, _specials[p])
		_specials.erase(p)
		for sp in special_pos:
			if sp != p:
				_append_unique(removed, [_remove_value(sp)])
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

func collapse_columns(check = true, fill = true):
	for x in width:
		for y in range(height-1, -1, -1):
			if get_value(x, y) == null:
				var yy = _first_non_null_above(x, y)
				if yy == null:
					break;

				_swap_value_with_special(Vector2i(x, yy), Vector2i(x, y))
				moved.emit(Vector2i(x, yy), Vector2i(x, y))

	if fill:
		update.emit()
		_data.print_data('Collapse')
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
	_data.print_data('Fill')

func _fill_random(x: int, y: int):
	var piece = _pieces.pick_random()
	_data.set_value(x, y, piece)
	return piece
