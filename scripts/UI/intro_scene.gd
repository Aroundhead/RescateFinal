extends Control

@onready var texture_rect = $TextureRect
@onready var label = $VBoxContainer/NinePatchRect/Label
@onready var skip_button = $VBoxContainer/NinePatchRect/skipButton
@onready var timer = $Timer

# Cinematic frames
var frames = [
	preload("res://assets/img/Intro_frame1.png"),
	preload("res://assets/img/Intro_frame2.png"),
	preload("res://assets/img/Intro_frame3.png"),
	preload("res://assets/img/Intro_frame4.png"),
	preload("res://assets/img/Intro_frame5.png"),
	preload("res://assets/img/Intro_frame6.png")
]

var narrations = [
	"La guerra nos forjó...",
	"En la batalla forjamos lazos eternos...",
	"Hace tiempo que ella ya no esta aqui conmigo...",
	"Algo no está bien esta noche...",
	"Una coordenada desconocida aparece...",
	"No hay forma en la que no reconozca esa ubicación."
]

var current_frame = 0

# Animation settings
var zoom_speed = 0.01
var move_speed = Vector2(0.2, 0) # (x, y) per second
var timer_interval = 4.0 # seconds each frame

# Guardamos nuestro tween activo
var active_tween: Tween

func _ready():
	texture_rect.stretch_mode = TextureRect.STRETCH_SCALE
	texture_rect.expand = true

	update_frame()
	skip_button.pressed.connect(_on_skip_pressed)

	timer.wait_time = timer_interval
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()

func update_frame():
	texture_rect.texture = frames[current_frame]
	label.text = narrations[current_frame]
	texture_rect.scale = Vector2.ONE
	texture_rect.position = Vector2.ZERO
	texture_rect.modulate = Color(1, 1, 1, 0) # Comienza transparente

	# Crear Tween de fade in
	if active_tween:
		active_tween.kill()
	active_tween = create_tween()
	active_tween.tween_property(texture_rect, "modulate", Color(1, 1, 1, 1), 1.0)

func _on_Timer_timeout():
	animate_frame()

	if current_frame < frames.size() - 1:
		current_frame += 1
		update_frame()
	else:
		get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn") # Cambia al primer nivel

func _on_skip_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/Level1.tscn")

func animate_frame():
	if active_tween:
		active_tween.kill()
	active_tween = create_tween()
	# Zoom lento
	active_tween.tween_property(texture_rect, "scale", texture_rect.scale + Vector2(zoom_speed, zoom_speed), timer_interval)
	# Movimiento suave
	active_tween.tween_property(texture_rect, "position", texture_rect.position + move_speed * timer_interval * 100, timer_interval)
