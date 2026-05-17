extends Camera2D

@export var personaje: CharacterBody2D
@export var activar_en_y: float = 300.0  # coordenada Y donde empieza a seguir

var siguiendo: bool = false

func _process(delta):
	if not siguiendo:
		if personaje.global_position.y >= activar_en_y:
			siguiendo = true
	else:
		global_position = personaje.global_position
