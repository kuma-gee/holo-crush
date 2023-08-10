class_name Specials

enum Type {
	ROW,
	COL,
	BOMB,
	COLOR_BOMB,
}


# TODO: global variable?
var min_match = 3

var _specials = {}

func get_all_specials():
	return _specials.keys()

func set_special(pos: Vector2i, type: Type):
	_specials[pos] = type

func get_special_type(p: Vector2i):
	if not p in _specials:
		return null
	return _specials[p]

func swap_special(pos: Vector2i, target: Vector2i):
	var v1 = _specials[pos] if pos in _specials else null
	var v2 = _specials[target] if target in _specials else null

	_specials.erase(pos)
	_specials.erase(target)

	if v1 != null:
		_specials[target] = v1
	if v2 != null:
		_specials[pos] = v2

func match_special_type(row_matched: Array, col_matched: Array):
	var row = row_matched.size()
	var col = col_matched.size()

	var matches = []
	var type: Type

	if row >= 5 or col >= 5:
		if row >= min_match:
			matches.append_array(row_matched)
		if col >= min_match:
			matches.append_array(col_matched)
		
		type = Type.COLOR_BOMB
	elif row >= 3 and col >= 3:
		matches.append_array(row_matched)
		matches.append_array(col_matched)
		type = Type.BOMB
	elif col == 4:
		matches.append_array(col_matched)
		type = Type.ROW
	elif row == 4:
		matches.append_array(row_matched)
		type = Type.COL
	
	var unique_matches = []
	for m in matches:
		if not m in unique_matches:
			unique_matches.append(m)
	
	return [unique_matches, type]

func activate_specials(p: Vector2i, data: GridData):
	var type = get_special_type(p)
	if type != null:
		_specials.erase(p)
		match type:
			Type.ROW: return _get_row(p, data)
			Type.COL: return _get_col(p, data)
			Type.BOMB: return _get_surrounding(p, data)
			Type.COLOR_BOMB: return _get_same_colors(p, data)
	
	return []

func _get_row(p: Vector2i, data: GridData):
	var result = []
	for x in data.width:
		result.append(Vector2i(x, p.y))
	return result


func _get_col(p: Vector2i, data: GridData):
	var result = []
	for y in data.height:
		result.append(Vector2i(p.x, y))
	return result

func _get_surrounding(p: Vector2i, data: GridData):
	var result = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]
	return result.map(func(d): return p + d).filter(func(d): return data.is_inside(d.x, d.y))

func _get_same_colors(p: Vector2i, data: GridData):
	var value = data.get_value_v(p)
	var result = []
	for y in data.height:
		for x in data.width:
			var v = data.get_value(x, y)
			if v == value:
				result.append(Vector2i(x, y))
	return result
