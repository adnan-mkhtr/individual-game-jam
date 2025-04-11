extends Label

@onready var cooldown_duration: float = 30.0
@onready var status_text: String = "Ready"

func _ready() -> void:
	self.text = status_text

func _process(delta: float) -> void:
	if get_parent().get_parent().is_full_heal_cooldown_active:
		cooldown_duration -= delta
		if cooldown_duration < 0:
			cooldown_duration = 30.0
			status_text = "Ready"
		else:
			var remaining_seconds: float = fmod(cooldown_duration, 60)
			status_text = "%02.0f sec" % remaining_seconds
		self.text = str(status_text)
