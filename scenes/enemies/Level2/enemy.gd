extends CharacterBody2D

@export var speed := 30
@export var chase_speed := 60
@export var gravity := 500
@export var max_health := 3
@export var attack_distance := 30.0

@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $detectionarea
@onready var hitbox = $HitBox
@onready var floor_ray = $FloorRay
@onready var attack_area = $AttackArea  # ✅ NUEVO

var patrol_direction := 1
var patrol_distance := 50
var start_position := Vector2.ZERO
var player_in_range := false
var player_reference: Node2D = null
var health := 0
var is_reloading := false
var can_attack := true

func _ready():
	start_position = global_position
	health = max_health
	sprite.play("Walk")
	floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if player_in_range and player_reference:
		var distance = global_position.distance_to(player_reference.global_position)
		var direction = sign(player_reference.global_position.x - global_position.x)

		if distance > attack_distance:
			# Persigue al jugador
			velocity.x = direction * chase_speed
			sprite.play("Run")
			face_player()
		else:
			# Ataca si está cerca
			velocity.x = 0
			sprite.play("Attack")
			attack_player()
	else:
		if not is_reloading:
			patrol(delta)

	move_and_slide()

func patrol(delta):
	velocity.x = patrol_direction * speed

	if is_on_floor() and not floor_ray.is_colliding():
		patrol_direction *= -1
		sprite.flip_h = patrol_direction == -1
		floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction

	sprite.play("Walk")

func face_player():
	if player_reference:
		var dir := player_reference.global_position.x < global_position.x
		sprite.flip_h = dir
		floor_ray.position.x = abs(floor_ray.position.x) * (-1 if dir else 1)

func attack_player():
	if can_attack:
		can_attack = false

		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player") and body.has_method("take_damage"):
				body.take_damage(1)
				print("🩸 ¡Golpeó al jugador!")

		await get_tree().create_timer(1.0).timeout
		can_attack = true

func _on_detection_area_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = true
		player_reference = parent
		print("🎯 Jugador detectado!")

func _on_detection_area_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = false
		player_reference = null
		print("👋 Jugador fuera de rango.")

func _on_hitbox_body_entered(body):
	if body.is_in_group("PlayerBullet"):
		health -= 1
		body.queue_free()
		if health <= 0:
			die()

func die():
	sprite.play("Dead")
	queue_free()
