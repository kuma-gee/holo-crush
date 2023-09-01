class_name AudioSlider
extends HSlider

@export var button: TextureButton
@export var bus_name := "Master"

var master_id
var vol_range = 50
var vol_offset = 15

func _ready():
	master_id = AudioServer.get_bus_index(bus_name)
	value_changed.connect(_volume_changed)
	update()
	
	if _has_button():
		button.toggled.connect(func(mute):
			AudioServer.set_bus_mute(master_id, mute)
			_update_states()
		)

func update():
	value = get_volume_percentage()

func _has_button():
	return button and button.toggle_mode

func _volume_changed(v: float):
	if v == 0:
		AudioServer.set_bus_mute(master_id, true)
	else:
		AudioServer.set_bus_mute(master_id, false)
		AudioServer.set_bus_volume_db(master_id, get_volume(v))
	
	_update_states()

func _update_states():
	var mute = AudioServer.is_bus_mute(master_id)
	if _has_button():
		button.button_pressed = mute
		
	modulate = Color.DARK_GRAY if mute else Color.WHITE

func get_volume(percentage: float) -> float:
	var vol_value = -vol_range + (vol_range * percentage / 100) # Volume from -vol_range to 0
	vol_value += vol_offset
	return vol_value

func get_volume_percentage():
	var volume = AudioServer.get_bus_volume_db(master_id)
	return (volume - vol_offset + vol_range) * 100 / vol_range # Just reversed the equation of #get_volume

