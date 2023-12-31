class_name MatchGrid
extends Node

signal invalid_swap(pos, dir)
signal wrong_swap(pos, dest)
signal swapped(pos, dest)
signal moved(pos, dest)

signal filled(pos, value)
signal created()
signal matched(pos, special)
signal icing_matched(pos)
signal special_activate(pos, fields)

signal refilled()

@export var level: LevelResource

var _data: GridData
var _specials: Specials
var _icings: Dictionary

# Don't touch! Only for testing
func get_data():
	return _data.get_data()

func create_data(values: Array, init: Array = []):
	_specials = Specials.new()
	_data = GridData.new(level.width, level.height, init, level.blocked)
	_icings = level.icings.duplicate()
	if init.size() == 0:
		_data.values = values.duplicate()
		_data.refill()

	created.emit()

func get_possible_move():
	var copy = _data.duplicate()
	for pos in get_cells():
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
		
		# Add separately afterwards so newly created are not immediatelly removed
		for s in special_matches:
			if not s in remove_matched:
				remove_matched.append(s)
		
		for m in remove_matched:
			_match(m, _specials.get_special_type(m))
		_data.print_data('Match')

	return has_matched

func _match(m, special):
	if get_icing_count(m) > 0:
		_icings[m] -= 1
		icing_matched.emit(m)
	matched.emit(m, special)

func get_icing_count(pos: Vector2i):
	return _icings[pos] if pos in _icings else 0

func has_icings():
	return not _icings.values().filter(func(x): return x > 0).is_empty()

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
				var special_pos = dest if dest in actual_match else actual_match[0]
				created_specials[special_pos] = [type, _data.get_value_v(special_pos)]

	return [special_matches, created_specials]

func has_specials():
	return _specials.get_all_specials().size() > 0

func activate_all_specials():
	if not has_specials():
		return
	
	var sp = _specials.get_all_specials()[0]
	var removed = [sp]
	_append_unique(removed, [_remove_value(sp)])
		
	_data.print_data('Activate specials')
	for m in removed:
		_match(m, null)

func _remove_value(p: Vector2i):
	var removed = []

	var fields = _specials.activate_specials(p, _data)
	if fields.size() > 0:
		special_activate.emit(p, fields)
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

func collapse_columns():
	for cell in get_cells(true):
		var x = cell.x
		var y = cell.y

		var dest = Vector2i(x, y)
		if get_value(x, y) == null:
			var yy = _collapse_for(Vector2i(x, y), dest)
			if yy != null: # currently only reason for not null is when it's blocked
				yy = _collapse_for(Vector2i(x-1, yy+1), dest)
				if yy != null:
					yy = _collapse_for(Vector2i(x+1, yy+1), dest)



	_data.print_data('Collapse')

func _collapse_for(start: Vector2i, dest: Vector2i):
	var yy = _first_non_null_above(start.x, start.y)
	if yy != null and get_value(start.x, yy) != null:
		_swap_value_with_special(Vector2i(start.x, yy), dest)
		moved.emit(Vector2i(start.x, yy), dest)
		return null
	return yy

func _first_non_null_above(x: int, y: int):
	for yy in range(y-1, -1, -1):
		if get_value(x, yy) != null or _data.is_blocked(x, yy):
			return yy
	return null


func fill_empty():
	for cell in get_cells(true):
		var x = cell.x
		var y = cell.y

		if get_value(x, y) == null:
			var value = _data.fill_random(x, y)
			filled.emit(Vector2i(x, y), value)
	
	_data.print_data('Fill')


func is_deadlocked():
	return get_possible_move() == null

func check_deadlock():
	var deadlock = is_deadlocked()
	if deadlock:
		_data.refill(_specials.get_all_specials())
		check_matches() # Usually does not contain matches, but just in case, let it be a win for the player
		refilled.emit()
	
	return deadlock

func get_cells(reverse = false):
	var result = []
	for x in level.width:
		if reverse:
			for y in range(level.height-1, -1, -1):
				if _data.is_inside(x, y):
					result.append(Vector2i(x, y))
		else:
			for y in level.height:
				if _data.is_inside(x, y):
					result.append(Vector2i(x, y))
	return result

func get_width():
	return level.width

func get_height():
	return level.height
