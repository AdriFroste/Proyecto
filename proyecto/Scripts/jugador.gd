extends CharacterBody2D

const SPEED = 128
const ACCELERATION = 1024
const FALL_SPEED = 300
const GRAVITY = 500

const JUMP_POWER_INITIAL = -200
const JUMP_CUT_MULTIPLIER = 0.1

const PREJUMP_TIME = 0.12
const COYOTE_TIME = 0.10

const WALL_JUMP_PUSH = 256

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var prejump_timer := 0.0
var coyote_timer := 0.0
var last_wall: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# --- INPUT DE SALTO (BUFFER) ---
	if Input.is_action_just_pressed("ui_up"):
		prejump_timer = PREJUMP_TIME

	# Consumir timers
	if prejump_timer > 0:
		prejump_timer -= delta
	if coyote_timer > 0:
		coyote_timer -= delta

	# Corte de salto (salto variable)
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# --- MOVIMIENTO HORIZONTAL ---
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)

	# --- FLIP DEL SPRITE ---
	if direction < 0:
		animated_sprite_2d.flip_h = true
	elif direction > 0:
		animated_sprite_2d.flip_h = false

	# --- GRAVEDAD ---
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, FALL_SPEED, GRAVITY * delta)
	else:
		velocity.y = 0
		coyote_timer = COYOTE_TIME

	# --- WALL SLIDING ---
	wall_sliding()

	# --- ANIMACIONES ---
	if is_on_floor():
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("Run")
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("Jump")
		else:
			animated_sprite_2d.play("Fell")

	# --- SALTO (BUFFER + COYOTE + WALL JUMP) ---
	if prejump_timer > 0 and (coyote_timer > 0 or last_wall != Vector2.ZERO):
		_jump()
		prejump_timer = 0
		coyote_timer = 0
		last_wall = Vector2.ZERO

	move_and_slide()

func wall_sliding():
	if !is_on_floor() and is_on_wall():
		last_wall = get_wall_normal()
	else:
		last_wall = Vector2.ZERO

func _jump():
	if last_wall != Vector2.ZERO:
		velocity.y = JUMP_POWER_INITIAL
		velocity.x = last_wall.x * WALL_JUMP_PUSH
		last_wall = Vector2.ZERO
	else:
		velocity.y = JUMP_POWER_INITIAL
