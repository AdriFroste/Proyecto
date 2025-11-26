extends CharacterBody2D
const SPEED = 200

const JUMP_FORCE = -400

const GRAVITY = 900



func _physics_process(delta):

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	velocity.x = direction * SPEED



	if not is_on_floor():

		velocity.y += GRAVITY * delta

	else:

		if Input.is_action_just_pressed("ui_accept"):

			velocity.y = JUMP_FORCE



	move_and_slide()
