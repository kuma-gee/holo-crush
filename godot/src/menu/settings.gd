extends Control

@export var container: Control

@onready var anim := $AnimationPlayer

func _ready():
	anim.play("RESET")

func _on_toggle_pressed():
	if anim.is_playing():
		return
	
	if container.position.y < 0:
		anim.play("show")
	else:
		anim.play_backwards("show")
