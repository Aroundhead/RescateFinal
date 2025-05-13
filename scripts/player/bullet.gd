extends Area2D

@export var speed = 600  
@export var shoot_sound: AudioStream

var direction = Vector2.ZERO  
var from_enemy := false  

func _ready():
	if shoot_sound:
		print("🔊 SHOOT: sonido asignado correctamente")
		var sfx = AudioStreamPlayer.new()
		sfx.stream = shoot_sound
		add_child(sfx)
		sfx.play()
	else:
		print("❌ SHOOT: sonido NO asignado")
		
func set_target_position(target_position: Vector2):
	direction = (target_position - global_position).normalized()

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	
	if position.length() > 10000:
		remove_from_group("PlayerBullet")
		remove_from_group("EnemyBullet")
		queue_free()

func set_source(is_enemy: bool):
	from_enemy = is_enemy
	if from_enemy:
		add_to_group("EnemyBullet")
	else:
		add_to_group("PlayerBullet")
