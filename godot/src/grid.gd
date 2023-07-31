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
			var node: Piece
			var loops = 0
			while node == null or (get_match_count(x, y) > 0 and loops < 100):
				piece = pieces.pick_random()
				loops += 1
				node = piece.instantiate()
				data[x][y] = node
			
			add_child(node)
			var pos = Vector2(x, y)
			node.swiped.connect(func(dir): _move_pieces(pos, dir))

func _move_pieces(pos: Vector2, dir: Vector2):
	var piece = data[pos.x][pos.y]
	var dest = pos + dir
	var other = data[dest.x][dest.y]
	
	print("Move ", pos, " - ", piece.type_name())
	print("Dest ", dest, " - ", other.type_name())
	
	data[pos.x][pos.y] = other
	data[dest.x][dest.y] = piece
	
	# TODO: actually move it inside the grid and disable input while moving
	var piece_pos = piece.global_position
	piece.move(other.global_position)
	other.move(piece_pos)
	

func get_match_count(x: int, y: int):
	var piece = _get_type(x, y)
	if piece != null:
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
