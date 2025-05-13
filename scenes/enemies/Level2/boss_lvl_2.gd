extends CharacterBody2D

@export var speed := 80
@export var chase_speed := 80
@export var gravity := 500
@export var max_health := 40
@export var attack_distance := 100.0
@export var origin_x := 0.0
@onready var sprite = $AnimatedSprite2D
@onready var detection_area = $detectionarea
@onready var hitbox = $HitBox
@onready var floor_ray = $FloorRay
@onready var attack_area = $AttackArea
@onready var health_bar = $CanvasLayer/HealthBar

var patrol_direction := 1
var start_position := Vector2.ZERO
var player_in_range := false
var player_reference: Node2D = null
var is_reloading := false
var can_attack := true

var health
var players_in_attack_range := []

func _ready():
	start_position = global_position
	sprite.play("Walk")
	floor_ray.position.x = abs(floor_ray.position.x) * patrol_direction

	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	health.init()




func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	if player_in_range and player_reference:
		var distance = global_position.distance_to(player_reference.global_position)
		var direction = sign(player_reference.global_position.x - global_position.x)

		if distance > attack_distance:
			velocity.x = direction * chase_speed
			sprite.play("Run")
			face_player()
		else:
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

		var offset = abs(floor_ray.position.x)
		floor_ray.position.x = offset * patrol_direction

	sprite.play("Walk")

func face_player():
	if player_reference:
		var dir := player_reference.global_position.x < global_position.x
		sprite.flip_h = dir
		floor_ray.position.x = abs(floor_ray.position.x) * (-1 if dir else 1)
		attack_area.position.x = abs(attack_area.position.x) * (-1 if dir else 1)

func attack_player():
	if can_attack:
		can_attack = false

		for area in players_in_attack_range:
			var parent = area.get_parent()
			if parent.is_in_group("player") and parent.has_method("take_damage"):
				parent.take_damage(1)
				print("🩸 ¡Golpeó al jugador!")

		await get_tree().create_timer(1.0).timeout
		can_attack = true

func _on_attack_area_area_entered(area: Area2D):
	if area.get_parent().is_in_group("player"):
		players_in_attack_range.append(area)

func _on_attack_area_area_exited(area: Area2D):
	if area.get_parent().is_in_group("player"):
		players_in_attack_range.erase(area)

func _on_detection_area_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = true
		player_reference = parent

func _on_detection_area_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		player_in_range = false
		player_reference = null

func _on_hit_box_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		health.take_damage(1)
		area.queue_free()

func die():
	print("☠️ Boss Nivel 2 derrotado.")
	set_physics_process(false)
	sprite.play("die")

	await sprite.animation_finished

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/levels/level_3.tscn")
