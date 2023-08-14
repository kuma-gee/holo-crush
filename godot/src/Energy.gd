extends Node

@export var max_energy := 5
@onready var energy := max_energy : set = _set_energy

func _set_energy(v):
	energy = v
	GameManager.energy_updated.emit(energy)
	
func use_energy():
	if energy > 0:
		self.energy -= 1
		return true
	return false
