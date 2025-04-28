extends CharacterBody2D

@export var speed = 200
@export var gravity = 500
@export var jump_force := -200
@export var bullet_scene: PackedScene
@onready var bullet_spawn = $BulletSpawn
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


# ⚡ Define la posición original del BulletSpawn
var bullet_spawn_offset_right = Vector2(18, -37)  # Ajusta según necesidad
var bullet_spawn_offset_left = Vector2(-18, -37)  # Igual pero al otro lado

func _ready():
	sprite.speed_scale = 1.7
	bullet_spawn.position = bullet_spawn_offset_right

func _physics_process(delta):
	var direction = Vector2.ZERO

	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_force

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		sprite.flip_h = false
		bullet_spawn.position = bullet_spawn_offset_right  # 🔥 Mueve el marker a la derecha
	elif Input.is_action_pressed("ui_left"):
		direction.x -= 1
		sprite.flip_h = true
		bullet_spawn.position = bullet_spawn_offset_left  # 🔥 Mueve el marker a la izquierda
	
	# Aplicar gravedad
	velocity.y += gravity * delta

	velocity.x = direction.x * speed
	move_and_slide()

	update_animation(direction)

func update_animation(direction):
	if Input.is_action_pressed("shoot"):
		sprite.play("shot")
	elif direction.x != 0:
		sprite.play("run")
	else:
		sprite.play("Idle")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shoot()
func shoot():
	if bullet_scene:
		# 🔥 Antes de disparar, voltear hacia donde esté el mouse
		var mouse_pos = get_global_mouse_position()

		# Si el mouse está a la derecha del jugador
		if mouse_pos.x > global_position.x:
			sprite.flip_h = false
			bullet_spawn.position = bullet_spawn_offset_right
		# Si el mouse está a la izquierda del jugador
		elif mouse_pos.x < global_position.x:
			sprite.flip_h = true
			bullet_spawn.position = bullet_spawn_offset_left
		
		# 🔥 Instanciar la bala normalmente
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = bullet_spawn.global_position
		bullet.set_target_position(mouse_pos)
