extends GridContainer


const pieces = [
	preload("res://src/piece/ina.tscn"),
	preload("res://src/piece/ame.tscn"),
	preload("res://src/piece/gura.tscn"),
	preload("res://src/piece/kiara.tscn"),
	preload("res://src/piece/calli.tscn"),
]

@export var rows := 8
@export var piece_size := 128

@onready var grid_size := Vector2(columns, rows)

var offset = Vector2.ZERO
var data: Array[Array] = []

func _ready():
	offset = _get_grid_offset()
	data = _create_data()
	_spawn_pieces()

func _get_grid_offset():
	var rect = get_viewport_rect()
	var remaining = rect.size - grid_size * piece_size
	return remaining / 2

func _create_data() -> Array[Array]:
	var arr: Array[Array] = []
	for x in columns:
		arr.append([])
		for y in rows:
			arr[x].append(null)
	return arr

func _spawn_pieces():
	for y in rows:
		for x in columns:
			var piece = pieces.pick_random()
			var loops = 0
			while loops == 0 or get_match_count(x, y) > 0 and loops < 100:
				piece = pieces.pick_random()
				loops += 1
				data[x][y] = piece.instantiate()
			
			add_child(data[x][y])

func get_match_count(x: int, y: int):
	var piece = _get_type(x, y)
	if piece:
		if x > 1:
			var row = [piece, _get_type(x-1, y), _get_type(x-2, y)]
			var count = row.count(piece)
			if count >= 3:
				return count
		if y > 1:
			var col = [piece, _get_type(x, y-1), _get_type(x, y-2)]
			var count = col.count(piece)
			if count >= 3:
				return count

	return 0

func _get_type(x: int, y: int):
	var d = data[x][y]
	return d.type if d else null
