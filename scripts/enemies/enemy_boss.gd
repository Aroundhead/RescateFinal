extends CharacterBody2D

@export var speed := 100
@export var move_range := 400
@export var bullet_scene: PackedScene
@export var max_health := 10

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_spawn: Marker2D = $Marker2D
@onready var timer: Timer = $ShootTimer
@onready var boss_health_bar = $CanvasLayer/HealthBar

var direction := 1
var origin_x := 0.0
var player_ref: Node2D = null
var movement_delay := 1.0
var movement_enabled := false

# Componentes
var health

func _ready():
	timer.start()
	
	# Inicializar componente de salud
	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	health.init()

	# Origen de patrullaje
	if origin_x == 0.0:
		origin_x = global_position.x

	# Buscar jugador
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_ref = players[0]

	# Conectar colisión
	if has_node("HitboxArea"):
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

func _on_shoot_timer_timeout():
	if not bullet_scene or not player_ref:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.set_target_position(player_ref.global_position)
	bullet.set_source(true)  # Marcada como bala enemiga

	if bullet.has_node("AnimatedSprite2D"):
		var anim_sprite = bullet.get_node("AnimatedSprite2D")
		anim_sprite.play("brain_bullet")

	get_tree().current_scene.add_child(bullet)

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
