extends Node2D

	
func _process(_delta: float) -> void:
	var enemy_count = 0

	for enemy in get_children():
		enemy_count += 1
	
	if enemy_count == 0:
		Global.show_portal = true
