extends Control

@onready var retry_button = $retryButton
@onready var quit_button = $QuitButton

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level1.tscn")

func _on_quit_pressed():
	get_tree().quit()
