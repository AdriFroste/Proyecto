extends CharacterBody2D

const SPEED = 200
const RAY_FLOOR_POSITION_X = 20
const RAY_WALL_TARGET_POSITION_X = 20

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D

func _ready():
	velocity.x = SPEED
	$raycast_floor_detection.position.x = RAY_FLOOR_POSITION_X
	$raycast_wall_detection.target_position.x = RAY_WALL_TARGET_POSITION_X
	sprite.play("default")
	$Area2D.body_entered.connect(_on_area_body_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if not $raycast_floor_detection.is_colliding():
		velocity.x *= -1
		$raycast_floor_detection.position.x *= -1
		$raycast_wall_detection.target_position.x *= -1

	move_and_slide()

func _on_area_body_entered(body):
	if body.is_in_group("personajes"):
		body._on_area_2d_body_entered(self)
