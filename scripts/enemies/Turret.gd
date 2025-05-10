extends Node2D

@export var bullet_scene: PackedScene
@export var max_health := 3

var target: Node2D = null
var player_in_range := false

@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var detection_area = $DetectionArea
@onready var hitbox = $Hitbox
@onready var health_bar = $HealthBar  # Solo si usas HealthBar visual

# COMPONENTES
var health

func _ready():
	rayCast.target_position = Vector2(0, 800)
	await get_tree().process_frame
	rayCast.enabled = true

	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

	# Componente de vida
	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	health.init()

func _physics_process(delta):
	if player_in_range and target:
		var angle_to_target = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		gunSprite.rotation = angle_to_target
		rayCast.target_position = gunSprite.to_local(target.global_position)
	else:
		rayCast.global_rotation = deg_to_rad(90)
		gunSprite.rotation = deg_to_rad(90)
		rayCast.target_position = Vector2(0, 800)

	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider == target and reloadTimer.is_stopped():
			shoot()
	elif not player_in_range and reloadTimer.is_stopped():
		shoot()

func shoot():
	print("💥 Disparo")
	rayCast.enabled = false

	if bullet_scene:
		var bullet: Node2D = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = rayCast.global_rotation

	reloadTimer.start()

# 👇 Aquí no se toca tu lógica de área
func _on_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("player"):
		print("✅ Jugador detectado (desde area)")
		target = parent
		player_in_range = true

func _on_area_exited(area: Area2D):
	var parent = area.get_parent()
	if parent == target:
		print("🚪 Jugador salió del rango (desde area)")
		target = null
		player_in_range = false

func _on_ReloadTimer_timeout():
	rayCast.enabled = true

# 👇 Nueva función para recibir daño
func _on_hitbox_area_entered(area: Area2D):
	var parent = area.get_parent()
	if parent.is_in_group("PlayerBullet"):
		health.take_damage(1)
		parent.queue_free()

func die():
	print("☠️ Torreta destruida")
	queue_free()
