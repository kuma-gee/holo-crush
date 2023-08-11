class_name GridUI
extends GridContainer

signal processing
signal processing_finished
signal turn_used
signal scored(value, combo)
signal explosion(pos)

const PIECE_MAP := {
	Piece.Type.BLUE: preload("res://src/piece/basic_blue.tscn"),
	Piece.Type.RED: preload("res://src/piece/basic_red.tscn"),
	Piece.Type.YELLOW: preload("res://src/piece/basic_yellow.tscn"),
	Piece.Type.GREEN: preload("res://src/piece/basic_green.tscn"),
	Piece.Type.PURPLE: preload("res://src/piece/basic_purple.tscn"),
	
	Piece.Type.INA: preload("res://src/piece/ina.tscn"),
	Piece.Type.AME: preload("res://src/piece/ame.tscn"),
	Piece.Type.GURA: preload("res://src/piece/gura.tscn"),
	Piece.Type.KIARA: preload("res://src/piece/kiara.tscn"),
	Piece.Type.CALLI: preload("res://src/piece/calli.tscn"),
}

@export var slot_scene: PackedScene
@export var data: MatchGrid
@export var pieces: Array[Piece.Type]
@export var pieces_root: Node2D

@export var collapse_timer: Timer
@export var fill_timer: Timer
@export var check_timer: Timer

var combo = 1
var default_score_value = 50
var special_multiplier = 2

var logger = Logger.new('Grid')

# https://www.youtube.com/watch?v=YhykrMFHOV4&list=PL4vbr3u7UKWqwQlvwvgNcgDL1p_3hcNn2
# https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7

func _ready():
	get_tree().get_root().size_changed.connect(_update_slots)
	
	_init_slots()
	data.created.connect(_create_pieces)
	data.swapped.connect(func(pos, dest):
		var slot = _get_slot(pos)
		var other = _get_slot(dest)
		slot.swap(other)
		await slot.swap_done
		data.check_matches(dest)
	)
	data.wrong_swap.connect(func(pos, dest):
		var slot = _get_slot(pos)
		var other = _get_slot(dest)
		slot.swap_wrong(other)
		await slot.swap_wrong_done
		processing_finished.emit()
	)
	data.invalid_swap.connect(func(pos, dir):
		var slot = _get_slot(pos)
		slot.invalid_swap(dir)
		processing_finished.emit()
	)

	data.special_activate.connect(func(pos, fields): _activate_special(pos, fields))

	data.matched.connect(func(m, special):
		var slot = _get_slot(m) as Slot
		slot.matched(special)

		var multiplier = special_multiplier if special != null else 1
		scored.emit(default_score_value * combo * multiplier, combo)
		collapse_timer.start()
	)
	collapse_timer.timeout.connect(func():
		data.collapse_columns()
		fill_timer.start()
	)

	data.moved.connect(func(pos, dest):
		var slot = _get_slot(pos)
		slot.move(_get_slot(dest))
		fill_timer.start()
	)
	fill_timer.timeout.connect(func():
		data.fill_empty()
		check_timer.start()
	)

	data.filled.connect(func(p, v):
		var slot = _get_slot(p)
		slot.piece = _spawn_piece(v)
		slot.fill_drop()
		check_timer.start()
	)
	data.refilled.connect(func():
		for y in range(data.height):
			for x in range(data.width):
				var pos = Vector2i(x, y)
				var type = data.get_value(x, y)
				var special = data.get_special_type(pos)
				var slot = _get_slot(pos)
				
				if special != null:
					continue

				var node = _spawn_piece(type)
				slot.replace(node)
				check_timer.start()
	)
	check_timer.timeout.connect(func(): _finish_check())
	
	data.create_data(pieces)

func _activate_special(pos, fields):
	if fields.size() == 0:
		return
	
#	var min_x = data.height
#	var max_x = 0
#	var min_y = data.height
#	var max_y = 0
#	for f in fields:
#		min_x = min(min_x, f.x)
#		max_x = max(max_x, f.x)
#		min_y = min(min_y, f.y)
#		max_y = max(max_y, f.y)
#
#	var is_horizontal = min_y == max_y
#	var is_vertical =  min_x == max_x
#	for f in fields:
#		var is_top = f.y == min_y
#		var is_right = f.x == max_x
#		var is_left = f.x == min_x
#		var is_bot = f.y == max_y
#		_get_slot(f).special(is_horizontal || is_top and not is_vertical, is_vertical || is_right and not is_horizontal, is_horizontal || is_bot and not is_vertical, is_vertical || is_left and not is_horizontal)

	explosion.emit(_get_slot(pos).get_pos())

func _finish_check():
	combo += 1

	if data.check_matches():
		return

	if data.check_deadlock():
		return

	combo = 1
	processing_finished.emit()

func highlight_possible_move():
	var move = data.get_possible_move()
	if move and move.size() > 0:
		for p in move:
			_get_slot(p).highlight()
		_get_slot(move[move.size() - 1]).jump()

func activate_specials():
	if data.has_specials():
		data.activate_all_specials()
		return true
	return false

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
			slot.height = data.height
			slot.swiped.connect(func(dir): 
				processing.emit()
				if data.swap(pos, pos + dir):
					turn_used.emit()
			)

# Should not be called with invalid position, ty
func _get_slot(pos: Vector2i):
	var idx = pos.y * columns + pos.x
	return get_child(idx)

func _spawn_piece(piece):
	var scene = PIECE_MAP[piece]
	var node = scene.instantiate()
	node.hide()
	pieces_root.add_child(node)
	node.type = piece
	return node

func _create_pieces():
	logger.debug("Creating initial pieces")
	
	for x in data.width:
		for y in data.height:
			var pos = Vector2i(x, y)
			var piece = data.get_value(pos.x, pos.y)
			var slot = _get_slot(pos)
			var node = _spawn_piece(piece)
			slot.replace(node)
