extends CharacterBody2D

@export var velocidad: float = 150.0
@export var lado: float = 200.0  # tamaño del cuadrado en píxeles

var punto_inicio: Vector2
var fase: int = 0  # 0=derecha, 1=abajo, 2=izquierda, 3=arriba

@onready var sprite = $AnimatedSprite2D

func _ready():
	punto_inicio = global_position
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	match fase:
		0:  # derecha
			velocity = Vector2(velocidad, 0)
			if global_position.x >= punto_inicio.x + lado:
				fase = 1
		1:  # abajo
			velocity = Vector2(0, velocidad)
			if global_position.y >= punto_inicio.y + lado:
				fase = 2
		2:  # izquierda
			velocity = Vector2(-velocidad, 0)
			if global_position.x <= punto_inicio.x:
				fase = 3
		3:  # arriba
			velocity = Vector2(0, -velocidad)
			if global_position.y <= punto_inicio.y:
				fase = 0

	move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
