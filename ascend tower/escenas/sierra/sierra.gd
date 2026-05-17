extends CharacterBody2D

@export var velocidad: float = 200.0
@export var distancia: float = 200.0

var pos_inicial: Vector2
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite = $AnimatedSprite2D

func _ready():
	pos_inicial = global_position
	velocity.x = velocidad
	$raycast_floor_detection.position.x = 20
	$raycast_wall_detection.target_position.x = 20
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if not $raycast_floor_detection.is_colliding():
		velocity.x *= -1
		$raycast_floor_detection.position.x *= -1
		$raycast_wall_detection.target_position.x *= -1
	elif abs(global_position.x - pos_inicial.x) >= distancia:
		velocity.x *= -1
		$raycast_floor_detection.position.x *= -1
		$raycast_wall_detection.target_position.x *= -1

	velocity.x = sign(velocity.x) * velocidad
	move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
