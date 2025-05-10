extends Node2D  # OJO: ya no Marker2D

@export var Enemy: PackedScene

func _ready():
	if Enemy:
		for child in get_children():
			if child is Marker2D:
				var enemy = Enemy.instantiate()
				get_parent().add_child(enemy)
				enemy.global_position = child.global_position
