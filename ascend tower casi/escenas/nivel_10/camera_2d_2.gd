extends Camera2D

@export var personaje: CharacterBody2D

func _process(delta):
	global_position.x = personaje.global_position.x
