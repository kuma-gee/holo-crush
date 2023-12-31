class_name Energy
extends Node

signal out_of_energy
signal energy_updated(energy)

@export var max_energy := 5
@onready var energy := max_energy : set = _set_energy

@export var restore_minutes := 30

var _logger = Logger.new("Energy")
var _last_used

func get_last_used_time():
	if _last_used == null:
		return -1
	return _last_used.get_time() 

func set_last_used_time(time: int):
	if time >= 0:
		_last_used = DateTime.new(time)

func _set_energy(v):
	energy = min(v, max_energy)
	energy_updated.emit(energy)
	
func use_energy(datetime: DateTime = DateTime.now()):
	if energy > 0:
		if _last_used == null:
			_last_used = datetime
			_logger.debug("Set last used time to %s" % _last_used)
		self.energy -= 1
		return true
	
	out_of_energy.emit()
	return false

func restore(now: DateTime = DateTime.now()):
	if _last_used == null:
		if energy < max_energy:
			_last_used = now
		return

	var diff_min = _last_used.get_diff_in_minutes(now)
	if diff_min < restore_minutes:
		#_logger.debug("%sm since last used, still %sm left" % [diff_min, restore_minutes - diff_min])
		return

	var restore_count = int(diff_min / restore_minutes)
	self.energy += restore_count
	_logger.debug("Restoring %s energy" % restore_count)

	if energy >= max_energy:
		_last_used = null
		return
	
	_last_used = _last_used.add_minutes(restore_count * restore_minutes)
	_logger.debug("New last used time %s " % _last_used)

func get_remaining_time(now: DateTime = DateTime.now()):
	if _last_used == null:
		return "00:00"
	
	var diff_sec = (restore_minutes * 60) - _last_used.get_diff_in_seconds(now)
	var dict = Time.get_datetime_dict_from_unix_time(diff_sec)
	return "%s:%s" % [_prefix_zero(dict.minute), _prefix_zero(dict.second)]

func _prefix_zero(n: int):
	if n <= 9:
		return "0%s" % n
	return str(n)
