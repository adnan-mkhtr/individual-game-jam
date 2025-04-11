extends Node2D

signal max_value_changed(new_max)
signal value_changed(new_amount)

@export var max_value: int = 10 : set = set_max
@onready var current_value: float = max_value : set = set_current

func _ready() -> void:
	initialize()

func set_max(new_max: int) -> void:
	max_value = new_max
	max_value = max(1, max_value)
	max_value_changed.emit(max_value)

func set_current(new_value: float) -> void:
	current_value = new_value
	current_value = clamp(current_value, 0, max_value)
	value_changed.emit(current_value)

func initialize() -> void:
	max_value_changed.emit(max_value)
	value_changed.emit(current_value)
