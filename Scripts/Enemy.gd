extends CharacterBody2D

const UP_DIRECTION = Vector2(0, -1)
var move_speed = 28
var gravity = 1000
var motion_velocity = Vector2()
var health = 10
var is_stunned = false
var is_dead = false
var is_destroyed = false
var is_moving_right = true
var stun_timer = 0
const STUN_DURATION = 1.5

func _ready() -> void:
	change_sprite($Walk)
	$AnimationPlayer.play("Walk")

func _physics_process(delta: float) -> void:
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			exit_stunned()
	
	if is_dead:
		check_dead()
		return
	
	if $AnimationPlayer.current_animation != "Attack" and not is_stunned:
		move_enemy(delta)

func move_enemy(delta: float) -> void:
	if is_dead:
		return
		
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

func enter_stunned():
	is_stunned = true
	stun_timer = STUN_DURATION
	velocity = Vector2.ZERO
	change_sprite($Idle)
	$AnimationPlayer.play("Idle")
	$StunnedTimer.start(STUN_DURATION)
#
func exit_stunned():
	is_stunned = false
	start_walk()

func hurt() -> void:
	if Global.is_level2 == true:
		health -= 4
	else:
		health -= 5

	if not is_stunned and health > 0:
		enter_stunned()

	if health <= 0:
		is_dead = true
		is_stunned = false
		change_sprite($Death)
		$AnimationPlayer.play("Death")
		
func hit() -> void:
	if not is_stunned:
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
	if not is_stunned:
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

func _on_StunnedTimer_timeout():
	exit_stunned()
