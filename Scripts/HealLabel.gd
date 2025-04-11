extends Label

@onready var cooldown_time: float = 20.0
@onready var display_message: String = "Ready"

func _ready() -> void:
	self.text = display_message

func _process(delta: float) -> void:
	if get_parent().get_parent().is_heal_cooldown_active:
		cooldown_time -= delta
		if cooldown_time < 0:
			cooldown_time = 20.0
			display_message = "Ready"
		else:
			var remaining_seconds: float = fmod(cooldown_time, 60)
			display_message = "%02.0f sec" % remaining_seconds
		self.text = str(display_message)
