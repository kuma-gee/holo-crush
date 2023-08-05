extends AudioStreamPlayer

@onready var timer := $Timer

func _ready():
	timer.timeout.connect(func(): super.play())

func play_debounce(time := 0.1):
	timer.start(time)
