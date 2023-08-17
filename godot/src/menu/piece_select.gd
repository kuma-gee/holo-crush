extends HBoxContainer

@export var select_slot: PackedScene

func _ready():
	for i in GameManager.selected_pieces.size():
		_create_slot(i)

func _create_slot(i):
	var slot = select_slot.instantiate()
	slot.index = i
	add_child(slot)