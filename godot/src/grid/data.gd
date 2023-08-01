class_name Data
extends Node

signal moved(pos, dest)
signal created()

@export var width := 9
@export var height := 9

var _data: Array[Array] = []

func create_data(pieces: Array):
	_data = []
	_data.resize(width)

	for x in width:
		_data[x] = []
		_data[x].resize(height)

		for y in height:
			var piece = pieces.pick_random()
			var loops = 0
			while loops < 100: 
				piece = pieces.pick_random()
				loops += 1
				_data[x][y] = piece 
				
				if get_match_count(x, y) == 0:
					break

	created.emit()

func get_match_count(x: int, y: int):
	var piece = get_value(x, y)
	if piece != null:
		if x > 1:
			var row = [piece, get_value(x-1, y), get_value(x-2, y)]
			var count = row.count(piece)
			if count >= 3:
				return count
		if y > 1:
			var col = [piece, get_value(x, y-1), get_value(x, y-2)]
			var count = col.count(piece)
			if count >= 3:
				return count

	return 0

func get_value(x: int, y: int):
	return _data[x][y]

func move(pos: Vector2i, dest: Vector2i):
	var piece = get_value(pos.x, pos.y)
	var other = get_value(dest.x, dest.y)
	_data[pos.x][pos.y] = other
	_data[dest.x][dest.y] = piece
	moved.emit(pos, dest)
