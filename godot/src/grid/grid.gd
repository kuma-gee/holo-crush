extends GridContainer

signal processing
signal processing_finished

signal match_finished

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
var queue = []
var is_processing_queue = false

# https://www.youtube.com/watch?v=YhykrMFHOV4&list=PL4vbr3u7UKWqwQlvwvgNcgDL1p_3hcNn2
# https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

# Actions
# [x] Initial Create Pieces
# [x] Swap
# [x] Matched
# [ ] Collapse
# [ ] Fill
# [ ] Refill

func _ready():
	get_tree().get_root().size_changed.connect(_update_slots)
	
	_init_slots()
	data.created.connect(func(): queue.append(_create_pieces))
	data.swapped.connect(_swap)
	data.invalid_swap.connect(_invalid_swap)
	data.matched.connect(_matched)

	data.moved.connect(_moved)
	data.filled.connect(_filled)
	
	data.create_data(pieces)

func _update_slots():
	await get_tree().create_timer(0.1).timeout
	for child in get_children():
		child.capture()

func _init_slots():
	columns = data.width
	for y in range(data.height):
		for x in range(data.width):
			var pos = Vector2i(x, y)
			var slot = slot_scene.instantiate() as Slot
			add_child(slot)
			slot.pos = pos
			slot.swiped.connect(func(pos, dir): data.swap(pos, pos + dir))

# Should not be called with invalid position, ty
func _get_slot(pos: Vector2i):
	var idx = pos.y * columns + pos.x
	return get_child(idx)

func _create_pieces():
	for x in data.width:
		for y in data.height:
			_add_piece(Vector2i(x, y))

func _add_piece(pos: Vector2i):
	var piece = data.get_value(pos.x, pos.y)
	var scene = PIECE_MAP[piece]

	var node = scene.instantiate()
	var slot = _get_slot(pos)
	slot.piece = node
	get_tree().current_scene.add_child(node)
	slot.capture()

func _invalid_swap(pos: Vector2i, dir: Vector2i):
	var slot = _get_slot(pos)
	slot.invalid_swap(dir)

func _swap(pos: Vector2i, dest: Vector2i):
	queue.append(func():
		var slot = _get_slot(pos)
		var other = _get_slot(dest)
		await slot.swap(other)
	)

func _moved(pos: Vector2i, dest: Vector2i):
	pass

func _matched(matches: Array):
	queue.append(func():
		var called = 0
		var done = []
		
		for p in matches:
			var slot = _get_slot(p) as Slot
			slot.matched()
			called += 1
			slot.match_done.connect(func():
				done.append(slot.pos)
				if done.size() >= called:
					match_finished.emit()
			)
			
		await match_finished
	)

func _filled(pos: Vector2):
	queue.append(func(): _add_piece(pos))

func _process(_delta):
	if not is_processing_queue and queue.size() > 0:
		is_processing_queue = true
		processing.emit()
		_process_queue()

func _process_queue():
	if queue.size() == 0:
		print("Process done")
		is_processing_queue = false
		processing_finished.emit()
		return

	var fn = queue.pop_front() as Callable
	print("Processing")
	await fn.call()
	_process_queue()
