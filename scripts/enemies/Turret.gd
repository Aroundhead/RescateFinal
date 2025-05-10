extends Node2D

@export var bullet_scene: PackedScene

var target: Node2D = null
var player_in_range := false

@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var detection_area = $DetectionArea

func _ready():
	rayCast.target_position = Vector2(0, 800)  # Down by default
	await get_tree().process_frame
	rayCast.enabled = true

	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player_in_range and target:
		var angle_to_target = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		gunSprite.rotation = angle_to_target
		rayCast.target_position = gunSprite.to_local(target.global_position)
	else:
		# No target: look straight down and keep shooting
		rayCast.global_rotation = deg_to_rad(90)
		gunSprite.rotation = deg_to_rad(90)
		rayCast.target_position = Vector2(0, 800)

	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider == target and reloadTimer.is_stopped():
			shoot()
	elif not player_in_range and reloadTimer.is_stopped():
		shoot()  # 🔫 Auto-shoot when idle

func shoot():
	print("💥 Disparo")
	rayCast.enabled = false

	if bullet_scene:
		var bullet: Node2D = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = rayCast.global_rotation

	reloadTimer.start()

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
