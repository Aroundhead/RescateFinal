extends Node2D  # 🔥 YA NO AREA2D, QUEDA EN NODE2D

@export var speed = 600  # Bullet speed
var direction = Vector2.ZERO  # Direction to move

func set_target_position(target_position: Vector2):
	direction = (target_position - global_position).normalized()

func _physics_process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	
	# Opcional: Borrar si sale muy lejos
	if position.length() > 5000:
		queue_free()
