extends GridContainer


const PIECE_MAP := {
	Piece.Type.INA: preload("res://src/piece/ina.tscn"),
	Piece.Type.AME: preload("res://src/piece/ame.tscn"),
	Piece.Type.GURA: preload("res://src/piece/gura.tscn"),
	Piece.Type.KIARA: preload("res://src/piece/kiara.tscn"),
	Piece.Type.CALLI: preload("res://src/piece/calli.tscn"),
}

@export var slot_scene: PackedScene
@export var data: Data

var pieces = PIECE_MAP.keys()

# https://www.youtube.com/watch?v=RO5pXiN6UnI
# https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

func _ready():
	_init_slots()
	data.created.connect(_create_pieces)
	data.moved.connect(_moved)
	data.failed_move.connect(_failed_move)
	
	data.create_data(pieces)

func _init_slots():
	columns = data.width
	for _i in range(data.width * data.height):
		var slot = slot_scene.instantiate()
		add_child(slot)

# Should not be called with invalid position, ty
func _get_slot(pos: Vector2i):
	var idx = pos.y * columns + pos.x
	return get_child(idx)

func _create_pieces():
	for x in data.width:
		for y in data.height:
			var piece = data.get_value(x, y)
			var scene = PIECE_MAP[piece]
			var node = scene.instantiate()

			var pos = Vector2i(x, y)
			var slot = _get_slot(pos)
			add_piece.call_deferred(slot, node)
			node.swiped.connect(func(dir): data.move(pos, pos + dir))

func add_piece(slot: Slot, piece: Piece):
	slot.piece = piece
	get_tree().current_scene.add_child(piece)
	slot.capture()

func _moved(pos: Vector2i, dest: Vector2i):
	var piece = _get_slot(pos)
	var other = _get_slot(dest)
	piece.move(other)

func _failed_move(pos: Vector2i, dir: Vector2i):
	var slot = _get_slot(pos)
	slot.failed_move(dir)
