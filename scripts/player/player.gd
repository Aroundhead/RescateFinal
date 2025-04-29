extends CharacterBody2D

@export var speed = 200
@export var gravity = 500
@export var jump_force := -200
@export var bullet_scene: PackedScene
@export var shoot_interval := 0.1  # 🚀 NUEVO: Tiempo entre disparos (0.1s para metralleta)
@onready var bullet_spawn = $BulletSpawn
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var bullet_spawn_offset_right = Vector2(18, -37)
var bullet_spawn_offset_left = Vector2(-18, -37)

var is_shooting = false  # 🚀 NUEVO
var shoot_timer = 0.0  # 🚀 NUEVO

func _ready():
	sprite.speed_scale = 1.7
	bullet_spawn.position = bullet_spawn_offset_right

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor() and not is_shooting:  # 🚫 No saltar mientras dispara
			velocity.y = jump_force

	if not is_shooting:  # 🚫 No moverse mientras dispara
		if Input.is_action_pressed("ui_right"):
			direction.x += 1
			sprite.flip_h = false
			bullet_spawn.position = bullet_spawn_offset_right
		elif Input.is_action_pressed("ui_left"):
			direction.x -= 1
			sprite.flip_h = true
			bullet_spawn.position = bullet_spawn_offset_left
	
	velocity.y += gravity * delta
	velocity.x = direction.x * speed
	move_and_slide()

	update_animation(direction)

	# 🚀 Manejar disparo continuo
	if is_shooting:
		shoot_timer -= delta
		if shoot_timer <= 0:
			shoot()
			shoot_timer = shoot_interval

func update_animation(direction):
	if Input.is_action_pressed("shoot"):
		sprite.play("shot")
	elif direction.x != 0:
		sprite.play("run")
	else:
		sprite.play("Idle")

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_shooting = true   # 🚀 Iniciar disparo continuo
				shoot_timer = 0      # 🚀 Disparar inmediatamente
			else:
				is_shooting = false  # 🚀 Detener disparo continuo

func shoot():
	if bullet_scene:
		var mouse_pos = get_global_mouse_position()

		if mouse_pos.x > global_position.x:
			sprite.flip_h = false
			bullet_spawn.position = bullet_spawn_offset_right
		elif mouse_pos.x < global_position.x:
			sprite.flip_h = true
			bullet_spawn.position = bullet_spawn_offset_left
		
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = bullet_spawn.global_position
		bullet.set_target_position(mouse_pos)
