extends Node2D

@export var bullet_scene: PackedScene

var target: Node2D = null
var player_in_range := false


@onready var gunSprite = $GunSprite
@onready var rayCast = $RayCast2D
@onready var reloadTimer = $RayCast2D/ReloadTimer
@onready var detection_area = $DetectionArea  # ← Asegúrate que exista

func _ready():
	rayCast.target_position = Vector2(800, 0) 
	await get_tree().process_frame
	rayCast.enabled = true

	detection_area.connect("body_entered", Callable(self, "_on_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_body_exited"))

func _physics_process(delta):
	if player_in_range and target:
		var angle_to_target = global_position.direction_to(target.global_position).angle()
		rayCast.global_rotation = angle_to_target
		gunSprite.rotation = angle_to_target

		if rayCast.is_colliding():
		
				if reloadTimer.is_stopped():
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

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("👀 Jugador en rango")
		target = body
		player_in_range = true

func _on_body_exited(body):
	if body == target:
		print("🚪 Jugador salió del rango")
		player_in_range = false
		target = null

func _on_ReloadTimer_timeout():
	rayCast.enabled = true
