extends Area2D

@export var posicion_spawn: Vector2

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("personajes"):
		print("posicion del personaje al tocar: ", body.global_position)
		ControladorGlobal.checkpoint = posicion_spawn
		ControladorGlobal.tiene_checkpoint = true
