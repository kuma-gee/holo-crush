extends GridContainer


const PIECE_MAP = {
	Piece.Type.INA: preload("res://src/piece/ina.tscn"),
	Piece.Type.AME: preload("res://src/piece/ame.tscn"),
	Piece.Type.GURA: preload("res://src/piece/gura.tscn"),
	Piece.Type.KIARA: preload("res://src/piece/kiara.tscn"),
	Piece.Type.CALLI: preload("res://src/piece/calli.tscn"),
}

@export var piece_size := 128
@export var slot_scene: PackedScene
@export var data: Data

var pieces = PIECE_MAP.keys()

# https://www.youtube.com/watch?v=RO5pXiN6UnI
# https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

func _ready():
	_init_slots()
	data.create_data(pieces)
	data.created.connect(_spawn_pieces)
	data.moved.connect(_moved)

func _init_slots():
	columns = data.width
	for _i in range(data.width * data.height):
		var slot = slot_scene.instantiate()
		add_child(slot)

func _get_slot(pos: Vector2):
	return get_child(pos.y * width + pos.x)

func _spawn_pieces():
	for x in data.width:
		for y in data.height:
			var piece = data.get_value(x, y)
			var scene = PIECE_MAP[piece]
			var node = scene.instantiate()
			get_tree().current_scene.add_child(node)

			var pos = Vector2(x, y)
			_get_slot(pos).piece = node
			node.swiped.connect(func(dir): data.move(pos, pos + dir))

func _moved(pos: Vector2, dest: Vector2):
	const piece = _get_slot(pos)
	const other = _get_slot(dest)
	piece.move(other)