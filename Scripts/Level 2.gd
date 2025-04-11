extends Node2D

@export var sceneName: String = "Level 2"

func _ready() -> void:
	Global.is_level2 = true
	Global.show_portal = false
	$Player/TextureRect2.visible = true
	$Portal.visible = false
	$Portal/Area2D/CollisionShape2D.disabled = true

func _process(_delta: float) -> void:
	if Global.show_portal:
		$Portal.visible = true
		$Portal.play("Portal")
		$Portal/Area2D/CollisionShape2D.disabled = false

func _on_Area2D_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().call_deferred("change_scene_to_file", "res://scenes/WinScreen.tscn")

func _on_FallArea_body_entered(body: Node2D) -> void:
	var current_scene = get_tree().get_current_scene().get_name()
	if body.name == "Player":
		if current_scene == sceneName:
			Global.lives -= 1
		if Global.lives == 0:
			get_tree().call_deferred("change_scene_to_file", "res://scenes/GameOver.tscn")
		else:
			get_tree().call_deferred("change_scene_to_file", str("res://scenes/" + sceneName + ".tscn"))
