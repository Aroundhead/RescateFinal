extends Node

var player: AudioStreamPlayer

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "Music"  # Solo si usas un bus llamado "Music"
