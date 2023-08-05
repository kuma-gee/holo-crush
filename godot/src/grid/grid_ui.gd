class_name GridUI
extends GridContainer

signal processing
signal processing_finished
signal turn_used
signal scored(value)

signal match_finished
signal collapse_finished
signal fill_finished
signal refresh_finished
signal create_finished

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

var queue = []
var is_processing_queue = false
var combo = 0
var default_score_value = 50
var special_multiplier = 2

var moving = []
var matches = []
var filling = []
var specials = []

var logger = Logger.new('Grid')

# https://www.youtube.com/watch?v=YhykrMFHOV4&list=PL4vbr3u7UKWqwQlvwvgNcgDL1p_3hcNn2
# https://medium.com/@thrivevolt/making-a-grid-inventory-system-with-godot-727efedb71f7


func _ready():
	get_tree().get_root().size_changed.connect(_update_slots)
	
	_init_slots()
	data.created.connect(func(): queue.append(_create_pieces))
	data.swapped.connect(func(pos, dest):
		queue.append(func():
			var slot = _get_slot(pos)
			var other = _get_slot(dest)
			slot.swap(other)
			await slot.swap_done
		)
	)
	data.invalid_swap.connect(func(pos, dir):
		var slot = _get_slot(pos)
		slot.invalid_swap(dir)
	)
	data.refilled.connect(func(): queue.append(_refresh_slots))

	data.special_activate.connect(func(p):) # TODO: activate special
	data.special_matched.connect(func(pos, aff, type, val): specials.append([pos, aff, type, val]))
	data.matched.connect(func(m): matches.append(m))
	data.moved.connect(func(pos, dest): moving.append([pos, dest]))
	data.filled.connect(func(p, v): filling.append([p, v]))
	data.update.connect(func(): 
		if matches.size() > 0:
			logger.debug("Queue Match %s" % [matches])
			logger.debug("Match with specials %s" % [specials])
			var x = matches.duplicate()
			var y = specials.duplicate()
			queue.append(func(): await _remove_matched(x, y))
			matches = []
			specials = []
		
		if moving.size() > 0:
			logger.debug("Queue Move %s" % [moving])
			var x = moving.duplicate()
			queue.append(func(): await _move_collapsed(x))
			moving = []

		if filling.size() > 0:
			logger.debug("Queue Fill %s" % [filling])
			var x = filling.duplicate()
			queue.append(func(): await _fill_pieces(x))

			filling = []
	)
	
	data.create_data(pieces)

func activate_specials():
	if data.has_specials():
		queue.append(func(): data.activate_all_specials())
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
			slot.swiped.connect(func(pos, dir): 
				if data.swap(pos, pos + dir):
					turn_used.emit()
			)

# Should not be called with invalid position, ty
func _get_slot(pos: Vector2i):
	var idx = pos.y * columns + pos.x
	return get_child(idx)

func _process(_delta):
	if not is_processing_queue and queue.size() > 0:
		is_processing_queue = true
		processing.emit()
		logger.debug("Start process: %s" % queue.size())
		_process_queue()

func _process_queue():
	if queue.size() == 0:
		combo = 0
		logger.debug("Process done")
		is_processing_queue = false
		processing_finished.emit()
		_refresh_slots(true)
		return

	var fn = queue.pop_front() as Callable
	logger.debug("Processing")
	await fn.call()
	_process_queue()

func _spawn_piece(piece):
	var scene = PIECE_MAP[piece]
	var node = scene.instantiate()
	pieces_root.add_child(node)
	node.type = piece
	return node

#################
# Queue Actions #
#################

func _refresh_slots(only_changed = false):
	if only_changed:
		logger.debug("Trying to refresh invalid pieces")
	else:
		logger.debug("Starting Refresh after refill")

	var called = {}
	
	for y in range(data.height):
		for x in range(data.width):
			var pos = Vector2i(x, y)
			var type = data.get_value(x, y)
			var special = data.get_special_type(pos)
			var slot = _get_slot(pos)
			
			if only_changed:
				if slot.piece == null or slot.piece.type != type:
					logger.debug("Pos %s has a different value: %s, %s" % [pos, slot.piece.type, type])
					var node = _spawn_piece(type)
					node.hide()
					if special != null:
						node.change_to(special)
					slot.replace(node)
				continue
			
			if special != null:
				continue

			called[pos] = 0
			var node = _spawn_piece(type)
			node.hide()
			slot.replace(node)
			slot.replace_done.connect(func():
				called[pos] = 1
				if called.values().all(func(v): return v == 1):
					refresh_finished.emit()
			)

	if not only_changed:
		logger.debug("Waiting for refresh")
		await refresh_finished

func _create_pieces():
	logger.debug("Creating initial pieces")
	
	var called = {}
	var finished = []
	
	for x in data.width:
		for y in data.height:
			var pos = Vector2i(x, y)
			var piece = data.get_value(pos.x, pos.y)
			var slot = _get_slot(pos)
			slot.replace(_spawn_piece(piece))
			
			called[pos] = 0
			slot.replace_done.connect(func():
				slot.capture()
				finished.append(pos)
				if finished.size() >= called.size():
					create_finished.emit()
			)
	await create_finished

func _fill_pieces(fills):
	logger.debug("Start fill %s" % [fills])

	var called = {}
	var finished = []
	for v in fills:
		var pos = v[0]
		var piece = v[1]
		var slot = _get_slot(pos)
		slot.piece = _spawn_piece(piece)
		slot.fill_drop()
		called[pos] = 0

		slot.fill_done.connect(func():
			finished.append(pos)
			if finished.size() >= called.size():
				fill_finished.emit()
		)

	logger.debug("Waiting for %s" % [called.keys()])
	await fill_finished

func _move_collapsed(moves):
	var called = {}
	var finished = []

	logger.debug("Start moving %s" % [moves])

	for m in moves:
		var slot = _get_slot(m[0])
		slot.move(_get_slot(m[1]))
		called[m] = 0
		slot.move_done.connect(func():
			finished.append(m)
			if finished.size() >= called.size():
				collapse_finished.emit()
		)
	
	logger.debug("Waiting for %s" % [called.keys()])
	await collapse_finished

func _remove_matched(matched: Array, special_matches: Array):
	combo += 1
	
	var called = {}
	var done = {}

	var counter_fn = func(p):
		done[p] = 0
		if done.size() >= called.size():
			match_finished.emit()
			
	logger.debug("Staring match %s - %s" % [matched, special_matches])

	var all_matched = []
	for m in matched:
		for p in m:
			all_matched.append(p)

	for x in special_matches:
		var dest = x[0]
		var affected = x[1]
		var type = x[2]
		var val = x[3]

		var target = _get_slot(dest) as Slot
		for pos in affected:
			if pos == dest:
				continue
			called[pos] = 0
			var slot = _get_slot(pos) as Slot
			slot.move_match(target)
			slot.match_done.connect(func(): counter_fn.call(pos))
			scored.emit(default_score_value * combo)
		
		if not dest in all_matched:
			called[dest] = 0
			var piece = _spawn_piece(val)
			target.change_special(type, piece)
			target.change_done.connect(func(): counter_fn.call(dest))
			scored.emit(default_score_value * combo * special_multiplier)
		else:
			pass # TODO: activate created special immediately
	
	for p in all_matched:
		called[p] = 0
		var slot = _get_slot(p) as Slot
		slot.matched()
		slot.match_done.connect(func(): counter_fn.call(p))
		scored.emit(default_score_value * combo)
		
	logger.debug("Waiting for %s" % [called.keys()])
	await match_finished

	for p in called:
		var slot = _get_slot(p) as Slot
		for c in slot.match_done.get_connections():
			slot.match_done.disconnect(c["callable"])
		for c in slot.change_done.get_connections():
			slot.change_done.disconnect(c["callable"])

