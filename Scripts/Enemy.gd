extends CharacterBody2D

const UP_DIRECTION = Vector2(0, -1)
var move_speed = 28
var gravity = 1000
var motion_velocity = Vector2()
var health = 10
var is_dead = false
var is_destroyed = false
var is_moving_right = true

func _ready() -> void:
	change_sprite($Walk)
	$AnimationPlayer.play("Walk")

func _physics_process(delta: float) -> void:
	if $AnimationPlayer.current_animation != "Attack":
		if not is_destroyed:
			move_enemy(delta)
			check_dead()

func move_enemy(delta: float) -> void:
	if not is_dead:
		velocity.x = move_speed if is_moving_right else -move_speed
		velocity.y += delta * gravity
		move_and_slide()
		if (not $RayCast2D.is_colliding() and is_on_floor()) or is_on_wall():
			is_moving_right = not is_moving_right
			scale.x = -scale.x

func check_dead() -> void:
	if is_dead:
		if not $AnimationPlayer.is_playing():
			is_destroyed = true
			queue_free()

func hurt() -> void:
	if Global.is_level2 == true:
		health -= 4
	else:
		health -= 5
	if health <= 0:
		is_dead = true
		change_sprite($Death)
		$AnimationPlayer.play("Death")
		get_child(0).queue_free()
		get_child(1).queue_free()
		get_child(2).queue_free()

func hit() -> void:
	$AttackDetector.monitoring = true
	if not $AttackSFX.playing:
		$AttackSFX.play(0)

func end_of_hit() -> void:
	$AttackDetector.monitoring = false

func start_walk() -> void:
	change_sprite($Walk)
	$AnimationPlayer.play("Walk")
	if $AttackSFX.playing:
		$AttackSFX.stop()

func _on_PlayerDetector_body_entered(_body: Node) -> void:
	change_sprite($Attack)
	$AnimationPlayer.play("Attack")

func _on_AttackDetector_body_entered(body: Node) -> void:
	if body.name == "Player":
		if position.x > body.position.x:
			body.flip_sprite(false)
		elif position.x < body.position.x:
			body.flip_sprite(true)
		body.hit()

func change_sprite(exception: Node) -> void:
	for child in get_children():
		if child is Sprite2D and child != exception:
			child.hide()
	exception.show()

func flip_sprite(direction: bool) -> void:
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = direction
