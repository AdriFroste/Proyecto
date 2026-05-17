extends CharacterBody2D

@export var velocidad: float = 150.0
@export var distancia: float = 200.0

var pos_inicial: Vector2
var jugador_encima: bool = false

func _ready():
	pos_inicial = global_position
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("personajes"):
		jugador_encima = true

func _on_body_exited(body):
	if body.is_in_group("personajes"):
		jugador_encima = false

func _physics_process(delta):
	if jugador_encima:
		if global_position.y > pos_inicial.y - distancia:
			var cuerpos = $Area2D.get_overlapping_bodies()
			var personaje_saltando = false
			for body in cuerpos:
				if body.is_in_group("personajes") and body.velocity.y < -50:
					personaje_saltando = true
			if personaje_saltando:
				velocity = Vector2.ZERO
			else:
				velocity = Vector2(0, -velocidad)
		else:
			velocity = Vector2.ZERO
	else:
		if global_position.y < pos_inicial.y:
			velocity = Vector2(0, velocidad)
		else:
			velocity = Vector2.ZERO
	move_and_slide()
