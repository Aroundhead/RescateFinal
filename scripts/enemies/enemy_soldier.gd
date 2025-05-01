extends CharacterBody2D

@export var speed := 30
@export var gravity := 500
@export var bullet_scene: PackedScene
@export var shoot_interval := 2.0
@export var max_health := 3

@onready var bullet_spawn = $BulletSpawn
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $detectionArea
@onready var hitbox = $Hitbox
@onready var floor_ray = $FloorRay

var shoot_timer = 0.0
var patrol_direction = 1
var patrol_distance = 50
var start_position = Vector2.ZERO
var player_in_range = false
var player_reference: Node2D = null
var health = 0
var is_reloading = false

func _ready():
	start_position = global_position
	health = max_health
	shoot_timer = shoot_interval
	sprite.play("Walk")
	floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if player_in_range and player_reference:
		if not is_reloading:
			velocity.x = 0
			shoot_timer -= delta
			if shoot_timer <= 0:
				shoot()
	else:
		if not is_reloading:
			patrol(delta)

	if not is_reloading and not player_in_range:
		sprite.play("Walk")

	move_and_slide()

func patrol(delta):
	velocity.x = patrol_direction * speed
	var turned = false

	if is_on_floor() and not floor_ray.is_colliding() and not turned:
		patrol_direction *= -1
		turned = true
		print("⚠️ No hay piso, girando")

	var dist = global_position.x - start_position.x
	if turned:
		sprite.flip_h = patrol_direction == -1
		floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction
		bullet_spawn.position.x = abs(bullet_spawn.position.x) * patrol_direction
		velocity.x = patrol_direction * speed

func face_player():
	if player_reference:
		var dir = player_reference.global_position.x < global_position.x

		# Flip visual
		sprite.flip_h = dir

		# Flip BulletSpawn
		var spawn_offset = bullet_spawn.position
		spawn_offset.x = abs(spawn_offset.x) * (-1 if dir else 1)
		bullet_spawn.position = spawn_offset

		# Flip RayCast
		floor_ray.position.x = abs(floor_ray.position.x) * (-1 if dir else 1)

func shoot():
	if bullet_scene and player_reference:
		face_player()

		var bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = bullet_spawn.global_position
		bullet.set_target_position(player_reference.global_position)

		if bullet.has_node("AnimatedSprite2D"):
			bullet.get_node("AnimatedSprite2D").play("enemyAttack")

		print("🚀 Enemy fired!")

		sprite.play("Attack")
		is_reloading = true
		shoot_timer = shoot_interval

		await get_tree().create_timer(0.5).timeout
		sprite.play("Reload")
		await get_tree().create_timer(1.0).timeout

		is_reloading = false
		shoot_timer = shoot_interval

func _on_area_entered(area: Area2D):
	print("🔎 Area entered: ", area.name)
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = true
		player_reference = parent
		print("🎯 Player detected!")

func _on_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = false
		player_reference = null
		print("👋 Player left range.")

func _on_hitbox_body_entered(body):
	if body.is_in_group("PlayerBullet"):
		health -= 1
		body.queue_free()
		if health <= 0:
			die()

func die():
	sprite.play("Dead")
	queue_free()
