extends CharacterBody2D
@export var velocidad: float = 150.0
@export var lado_horizontal: float = 200.0
@export var lado_vertical: float = 200.0
var fase: int = 0
var pos_inicial: Vector2
@onready var sprite = $AnimatedSprite2D
func _ready():
	pos_inicial = global_position
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)
func _physics_process(delta):
	match fase:
		0: velocity = Vector2(0, velocidad)
		1: velocity = Vector2(velocidad, 0)
		2: velocity = Vector2(0, -velocidad)
		3: velocity = Vector2(-velocidad, 0)
	match fase:
		0: if global_position.y >= pos_inicial.y + lado_vertical: fase = 1
		1: if global_position.x >= pos_inicial.x + lado_horizontal: fase = 2
		2: if global_position.y <= pos_inicial.y: fase = 3
		3: if global_position.x <= pos_inicial.x: fase = 0
	move_and_slide()
func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
