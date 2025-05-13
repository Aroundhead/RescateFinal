extends Control

@onready var play_button: Button = $CanvasLayer/PlayButton
@onready var quit_button: Button = $CanvasLayer/PlayButton/QuitButton

func _ready():
	var song = preload("res://assets/sfx/mainmenu.mp3")
	MusicManager.player.stop()
	MusicManager.player.stream = song
	MusicManager.player.play()
	
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("▶️ Iniciando juego...")
	get_tree().change_scene_to_file("res://scenes/ui/intro_scene.tscn")  # Ajusta si tu path es distinto

func _on_quit_pressed():
	print("👋 Saliendo del juego...")
	get_tree().quit()
