extends CharacterBody2D

const UP = Vector2(0, -1)
var speed = 150
var gravity = 1425
var jump_height = -300
var heal_cooldown_time = 20
var full_heal_cooldown_time = 30
var heal_duration_time = 5
var death_position = Vector2.ZERO

@onready var health = $Health
@onready var heal_cooldown_timer = $HealCoolDown
@onready var heal_duration_timer = $HealDuration
@onready var full_heal_cooldown_timer = $FullHealCoolDown

var can_heal = false
var is_running = false
var is_attacking = false
var is_jumping = false
var is_falling = false
var has_double_jumped = false
var is_hurt = false
var is_dead = false
var is_healing = false
var is_full_healing = false
var is_game_over = false
var is_heal_cooldown_active = false
var is_full_heal_cooldown_active = false

func _ready():
	change_sprite($Idle)
	$AnimationPlayer.play("Idle")
	setup_bgm()
	initialize_health()

func setup_bgm():
	$BGM.stream.loop = true
	$BGM.play()

func initialize_health():
	var player_health = $Health
	var health_bar = $Health/HealthBar
	
	player_health.connect("value_changed", Callable(health_bar, "set_value"))
	player_health.connect("max_value_changed", Callable(health_bar, "set_max"))
	player_health.initialize()

func _physics_process(delta):
	if not is_game_over:
		check_if_dead()
	
	check_game_over()
	
	if not is_dead:
		handle_input()
		velocity.y += delta * gravity
		move_and_slide()

func handle_input():
	velocity.x = 0
	check_idle()
	
	if not is_jumping and not is_falling and not is_healing and not is_full_healing:
		check_attack()
	
	check_double_jump()
	
	if not is_attacking:
		check_heal()
		check_full_heal()
		if not is_healing and not is_full_healing and not is_hurt:
			check_jump()
			check_fall()
			check_run()

func check_idle():
	if not is_running and not is_attacking and not is_jumping and not is_falling and not is_healing and not is_full_healing and not is_hurt:
		change_sprite($Idle)
		$AnimationPlayer.play("Idle")

func check_attack():
	if Input.is_action_just_pressed("Attack"):
		change_sprite($Attack)
		$AnimationPlayer.play("Attack")
		if not $AttackSFX.playing:
			$AttackSFX.play(0)
		is_attacking = true
		if not $Attack.flip_h:
			$AttackArea/AttackCollision.disabled = false
		elif $Attack.flip_h:
			$AttackArea/AttackCollision2.disabled = false
	if not $AnimationPlayer.is_playing():
		is_attacking = false
		$AttackSFX.stop()
		if not $Attack.flip_h:
			$AttackArea/AttackCollision.disabled = true
		elif $Attack.flip_h:
			$AttackArea/AttackCollision2.disabled = true

func check_heal():
	if Input.is_action_just_pressed("Heal") and heal_cooldown_timer.is_stopped():
		if not is_jumping and not is_falling and not is_full_healing:
			can_heal = true
			is_healing = true
			change_sprite($Heal)
			$AnimationPlayer.play("Heal")
			heal_cooldown_timer.start(heal_cooldown_time)
			is_heal_cooldown_active = true
			heal_duration_timer.start(heal_duration_time)
	
	if heal_cooldown_timer.is_stopped():
		is_heal_cooldown_active = false
	
	if not $AnimationPlayer.is_playing():
		is_healing = false
	
	if can_heal == true:
		health.current_value += 0.02
	
	if heal_duration_timer.is_stopped() or (health.current_value >= health.max_value):
		can_heal = false

func check_full_heal():
	if Input.is_action_just_pressed("FullHeal") and full_heal_cooldown_timer.is_stopped() and Global.is_level2:
		if not is_jumping and not is_falling and not is_healing:
			is_full_healing = true
			change_sprite($FullHeal)
			$AnimationPlayer.play("FullHeal")
			full_heal_cooldown_timer.start(full_heal_cooldown_time)
			is_full_heal_cooldown_active = true
	
	if full_heal_cooldown_timer.is_stopped():
		is_full_heal_cooldown_active = false
	
	if is_full_healing and not $AnimationPlayer.is_playing():
		health.current_value = health.max_value
		is_full_healing = false

func check_jump():
	if not is_jumping and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_height
		is_jumping = true
		change_sprite($Jump)
		$AnimationPlayer.play("Jump")
	if is_jumping and velocity.y == 0:
		is_jumping = false

func check_double_jump():
	if not has_double_jumped and is_jumping and Input.is_action_just_pressed("Jump"):
		velocity.y += jump_height
		has_double_jumped = true
		change_sprite($Jump)
		$AnimationPlayer.play("Jump")
	
	if has_double_jumped and velocity.y == 0:
		has_double_jumped = false

func check_fall():
	if velocity.y > 200:
		is_falling = true
		change_sprite($Fall)
		$AnimationPlayer.play("Fall")
	if velocity.y == 0:
		is_falling = false

func check_run():
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		is_running = true
		if not is_jumping and not is_falling:
			change_sprite($Run)
			$AnimationPlayer.play("Run")
		if Input.is_action_pressed("ui_right"):
			flip_sprite(false)
			velocity.x += speed
		elif Input.is_action_pressed("ui_left"):
			flip_sprite(true)
			velocity.x -= speed
	elif Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_left"):
		is_running = false

func check_game_over():
	if is_game_over and not $AnimationPlayer.is_playing():
		get_tree().call_deferred("change_scene_to_file", "res://scenes/GameOver.tscn")

func check_if_dead():
	if is_hurt:
		var knockback = Vector2()
		if $Hurt.flip_h:
			knockback.x = 100
		else:
			knockback.x = -100
		velocity = knockback
		move_and_slide()
		if not $AnimationPlayer.is_playing():
			is_hurt = false
		velocity.x = 0
	if health.current_value <= 0 and not is_dead:
		is_dead = true
		if Global.is_level2 == true:
			death_position = position
			Global.lives -= 1
		change_sprite($Death)
		$AnimationPlayer.play("Death")
	if is_dead and not $AnimationPlayer.is_playing():
		if Global.lives > 0 and Global.is_level2 == true:
			respawn()
		else:
			is_game_over = true
func respawn():
	is_dead = false
	health.current_value = health.max_value
	position = death_position
	change_sprite($Idle)
	$AnimationPlayer.play("Idle")
	
func hit():
	if not is_dead and not is_hurt and not is_full_healing:
		is_hurt = true
		if Global.is_level2 == true:
			health.current_value -= 4
		else:
			health.current_value -= 3
		change_sprite($Hurt)
		$AnimationPlayer.play("Hurt")

func _on_AttackArea_body_entered(body):
	if "Enemy" in body.get_name():
		body.hurt()
		
func change_sprite(exception: Node) -> void:
	for child in get_children():
		if child is Sprite2D and child != exception:
			child.hide()
	exception.show()

func flip_sprite(direction: bool) -> void:
	for child in get_children():
		if child is Sprite2D:
			child.flip_h = direction
			
