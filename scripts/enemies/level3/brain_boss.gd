extends CharacterBody2D

@export var speed := 100
@export var move_range := 400
@export var bullet_scene: PackedScene
@export var max_health := 100
@export var bullet_hell_count := 24  # Número de balas en el círculo

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_spawn: Marker2D = $Marker2D
@onready var timer: Timer = $ShootTimer
@onready var boss_health_bar = $CanvasLayer/HealthBar
@onready var hitbox_area = $HitboxArea

var direction := -1  # Empieza yendo hacia la izquierda
var origin_x := 0.0
var movement_delay := 1.0
var movement_enabled := false

var player_ref: Node2D = null
var health  # HealthComponent
var is_attacking := false
var state_timer: Timer 
func _ready():
	health = preload("res://scripts/common/HealthComponent.gd").new(self)
	health.init()

	if origin_x == 0.0:
		origin_x = global_position.x

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player_ref = players[0]

	hitbox_area.connect("area_entered", Callable(self, "_on_hitbox_area_entered"))

	# Desactiva hitbox y empieza en modo no ataque
	hitbox_area.set_deferred("monitoring", false)
	sprite.play("default")
	is_attacking = false
	movement_enabled = true

	# Temporizador para alternar estados
	state_timer = Timer.new()
	state_timer.wait_time = 5
	state_timer.one_shot = false
	state_timer.autostart = true
	state_timer.timeout.connect(_toggle_attack_state)
	add_child(state_timer)


func _process(delta):
	if not movement_enabled:
		movement_delay -= delta
		if movement_delay <= 0:
			movement_enabled = true

func _toggle_attack_state():
	is_attacking = !is_attacking
	
	if is_attacking:
		# Cambia a estado de disparo
		movement_enabled = false
		hitbox_area.set_deferred("monitoring", true)
		sprite.play("open")
		timer.start()
	else:
		# Cambia a estado de persecución
		movement_enabled = true
		hitbox_area.set_deferred("monitoring", false)
		sprite.play("default")
		timer.stop()


func _physics_process(delta):
	if not movement_enabled:
		return

	velocity.x = direction * speed
	move_and_slide()

	if abs(global_position.x - origin_x) > move_range:
		direction *= -1
		sprite.flip_h = direction < 0

func _on_shoot_timer_timeout():
	if not is_attacking or not bullet_scene:
		return

	for i in bullet_hell_count:
		var angle = i * (TAU / bullet_hell_count)
		var dir = Vector2(cos(angle), sin(angle)).normalized()

		var bullet = bullet_scene.instantiate()
		bullet.global_position = bullet_spawn.global_position
		bullet.set_source(true)
		bullet.set_direction(dir)

		if bullet.has_node("AnimatedSprite2D"):
			bullet.get_node("AnimatedSprite2D").play("brain_bullet")

		get_parent().add_child(bullet)

func _on_hitbox_area_entered(area: Area2D):
	if is_attacking and area.is_in_group("PlayerBullet"):
		health.take_damage(1)
		area.queue_free()
		
		if health.current_health <= 0:
			die()
func die():
	print("☠️ Boss derrotado.")
	timer.stop()
	set_physics_process(false)

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0) # Fade out opcional
	await tween.finished

	get_tree().change_scene_to_file("res://scenes/ui/final_scene.tscn")	
