extends CharacterBody2D

@export var velocidad: float = 200.0
@export var distancia: float = 200.0

var punto_inicio: Vector2
var direccion: int = 1

@onready var sprite = $AnimatedSprite2D

func _ready():
	punto_inicio = global_position
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	velocity.x = velocidad * direccion

	if global_position.x >= punto_inicio.x + distancia:
		direccion = -1
	elif global_position.x <= punto_inicio.x:
		direccion = 1

	move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
