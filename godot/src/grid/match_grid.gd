class_name MatchGrid
extends Node

signal invalid_swap(pos, dir)
signal wrong_swap(pos, dest)
signal swapped(pos, dest)
signal moved(pos, dest)

signal filled(pos, value)
signal created()
signal matched(pos)
signal special_matched(pos, affected, type, value)
signal special_activate(pos)

signal refilled()
signal update()

@export var width := 9
@export var height := 9
@export var debug := false

var _data: GridData
var _specials: Specials

# Don't touch! Only for testing
func set_data(d):
	_data = d
func get_data():
	return _data.get_data()

func create_data(values: Array, init: Array = []):
	_specials = Specials.new()
	_data = GridData.new(width, height, init)
	if init.size() == 0:
		_data.values = values.duplicate()
		_data.refill()

	created.emit()

func get_possible_move():
	var copy = _data.duplicate()
	for y in height:
		for x in width:
			var pos = Vector2i(x, y)
			var dir_to_check = [Vector2i.UP, Vector2i.RIGHT]

			for dir in dir_to_check:
				var dest = pos + dir
				copy.swap_value(pos, dest)

				var matches = copy.get_match_counts()
				if matches.size() > 0:
					var result = matches.keys()
					if pos in result:
						result.erase(pos)
						result.append(dest)
					elif dest in result:
						result.erase(dest)
						result.append(pos)
					return result
				
				copy.swap_value(pos, dest)
	return null

func is_deadlocked():
	return get_possible_move() == null

func get_special_type(p: Vector2i):
	return _specials.get_special_type(p)

func get_value(x: int, y: int):
	return _data.get_value(x, y)

func _swap_value_with_special(p1: Vector2i, p2: Vector2i):
	_data.swap_value(p1, p2)
	_specials.swap_special(p1, p2)

func swap(pos: Vector2i, dest: Vector2i):
	var value = get_value(pos.x, pos.y)
	if value == null:
		return # Invalid move, no animation needed either

	var other = get_value(dest.x, dest.y)
	if other == null:
		invalid_swap.emit(pos, dest - pos)
		return
	
	var test_swap = _data.duplicate()
	test_swap.swap_value(pos, dest)
	var count = test_swap.get_match_counts()
	if count.size() > 0:
		_swap_value_with_special(pos, dest)
		swapped.emit(pos, dest)
		check_matches(dest)

		if is_deadlocked():
			_data.refill(_specials.get_all_specials())
			check_matches() # Usually does not contain matches, but just in case, let it be a win for the player
			refilled.emit()
		_data.print_data('Swap')

		return true
	else:
		wrong_swap.emit(pos, dest)
	
	return false

func check_matches(dest: Vector2i = Vector2i(-1, -1)):
	var counts = _data.get_match_counts()
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
			_specials.set_special(special, type)
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
		
		var result = _specials.match_special_type(row_matched, col_matched)
		var actual_match = result[0]
		var type = result[1]

		if actual_match != null and type != null:
			if actual_match.size() > 0:
				_append_unique(special_matches, [actual_match])
				var special_pos = _create_special(actual_match, dest, type)
				created_specials[special_pos] = [type, _data.get_value_v(special_pos)]

	return [special_matches, created_specials]

func _create_special(matches: Array, dest: Vector2i, type: int):
	var pos = dest if dest in matches else matches[0]
	special_matched.emit(pos, matches, type, get_value(pos.x, pos.y))
	return pos

func has_specials():
	return _specials.get_all_specials().size() > 0

func activate_all_specials():
	if not has_specials():
		return
	
	var sp = _specials.get_all_specials()[0]
	var removed = [sp]
	_append_unique(removed, [_remove_value(sp)])
		
	matched.emit(removed)
	update.emit()
	_data.print_data('Activate specials')
	collapse_columns()

func _remove_value(p: Vector2i):
	var removed = []

	var fields = _specials.activate_specials(p, _data)
	if fields.size() > 0:
		special_activate.emit(p)
		for sp in fields:
			if sp != p:
				_append_unique(removed, [_remove_value(sp)])

	# Specials might need the current value, so remove it after
	_data.set_value_v(p, null)
	if not p in removed:
		removed.append(p)

	return removed

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
				var value = _data.fill_random(x, y)
				filled.emit(Vector2i(x, y), value)
	
	update.emit()
	_data.print_data('Fill')
