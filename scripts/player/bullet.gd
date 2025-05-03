extends Area2D

@export var speed = 600  # Bullet speed
var direction = Vector2.ZERO  # Direction to move
var from_enemy := false  # ← esta variable se setea al instanciar

func set_target_position(target_position: Vector2):
	direction = (target_position - global_position).normalized()

func _physics_process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	
	# Opcional: Borrar si sale muy lejos
	if position.length() > 5000:
		remove_from_group("PlayerBullet")
		remove_from_group("EnemyBullet")
		queue_free()


func set_source(is_enemy: bool):
	from_enemy = is_enemy
	if from_enemy:
		add_to_group("EnemyBullet")
	else:
		add_to_group("PlayerBullet")
