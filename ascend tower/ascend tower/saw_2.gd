extends CharacterBody2D

@export var velocidad: float = 200.0
@export var distancia: float = 200.0  # píxeles que recorre hacia arriba y abajo

var punto_inicio: float
var direccion: int = 1  # 1 = abajo, -1 = arriba

@onready var sprite = $AnimatedSprite2D

func _ready():
	punto_inicio = global_position.y
	velocity.y = velocidad * direccion
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	velocity.y = velocidad * direccion

	# Si llegó al límite inferior, sube
	if global_position.y >= punto_inicio + distancia:
		direccion = -1
	# Si llegó al límite superior, baja
	elif global_position.y <= punto_inicio - distancia:
		direccion = 1

	move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
