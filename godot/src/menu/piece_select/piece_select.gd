extends HBoxContainer

#@export var piece_selectable_container: Control
#@export var select_slot: PackedScene
#
#func _ready():
#	for i in GameManager.selected_pieces.size():
#		_create_slot(i)
#
#	piece_selectable_container.selected.connect(_on_selected)
#
#func _on_selected(idx, piece):
#	for slot in get_children():
#		if slot.index == idx:
#			slot.update()
#
#func _create_slot(i):
#	var slot = select_slot.instantiate()
#	slot.index = i
#	slot.select_for.connect(_on_select_for)
#	add_child(slot)
#
#func _on_select_for(idx, pos):
#	piece_selectable_container.show_selectable_pieces(idx, pos)
