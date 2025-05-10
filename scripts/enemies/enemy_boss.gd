extends CharacterBody2D

@export var speed := 100
@export var move_range := 400
@export var bullet_scene: PackedScene
@export var max_health := 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var bullet_spawn: Marker2D = $Marker2D
@onready var timer: Timer = $ShootTimer
@onready var boss_health_bar = $CanvasLayer/HealthBar

var direction := 1
var origin_x := 0.0
var health

var movement_delay := 1.0
var movement_enabled := false

func _ready():
	timer.start()
	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	health.init()
	if origin_x == 0.0:
		origin_x = global_position.x
	$HitboxArea.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))

func _process(delta):
	if not movement_enabled:
		movement_delay -= delta
		if movement_delay <= 0:
			movement_enabled = true

func _physics_process(delta):
	if not movement_enabled:
		return

	velocity.x = direction * speed
	move_and_slide()

	if abs(global_position.x - origin_x) > move_range:
		direction *= -1
		sprite.flip_h = direction < 0

func _on_ShootTimer_timeout():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = bullet_spawn.global_position
		bullet.velocity = Vector2(0, 200) 
		get_tree().current_scene.add_child(bullet)
		print("💥 Bala instanciada en:", bullet.global_position)
		
func _on_hitbox_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		print("🔥 Boss impactado por bala del jugador")
		health.take_damage(1)
		area.queue_free() 

func die():
	print("☠️ Boss ha muerto.")
	timer.stop()
	set_physics_process(false)
	queue_free()
	
