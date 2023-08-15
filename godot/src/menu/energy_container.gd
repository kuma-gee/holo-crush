class_name EnergyContainer
extends Control

func _ready():
	set_energy(GameManager.get_energy())

func set_energy(v):
	for i in get_child_count():
		var child = get_child(i)
		child.value = i < v
