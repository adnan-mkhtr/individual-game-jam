extends Node2D

func _ready() -> void:
	Global.is_level2 = false

func _on_StartButton_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://scenes/Lobby 1.tscn")

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
