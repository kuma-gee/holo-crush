class_name EnergyContainer
extends Control

func _ready():
	_set_energy(GameManager.energy.energy)
	
	GameManager.energy.out_of_energy.connect(_out_of_energy)
	GameManager.energy.energy_updated.connect(_set_energy)

func _set_energy(v):
	for i in get_child_count():
		var child = get_child(i)
		child.value = i < v

func _out_of_energy():
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_CUBIC)#.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate", Color.WHITE, 0.1).set_trans(Tween.TRANS_CUBIC)#.set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_CUBIC)#.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate", Color.WHITE, 0.1).set_trans(Tween.TRANS_CUBIC)#.set_ease(Tween.EASE_IN)
