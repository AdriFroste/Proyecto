extends CharacterBody2D
# --- Constantes de Movimiento ---
const SPEED = 256
const ACCELERATION = 2048
const FALL_SPEED = 512
const GRAVITY = 512
# --- Constantes de Salto ---
const JUMP_POWER_INITIAL = -300
const JUMP_POWER = 128
const JUMP_DISTANCE = -256
var jump_time_max = 0.1
var jump_timer = 0
const COYOTE_TIME = 0.1
# --- Constantes de Pared ---
const WALL_JUMP_PUSH = 300
const WALL_SLIDE_START_SPEED = 32
const WALL_SLIDE_ACCEL = 100
var current_wall_friction = 0.0
# --- Variables de Estado ---
var tateobesu = false
var coyote_timer = 0.0
var last_wall: Vector2 = Vector2.ZERO
var _saltando_desde_suelo: bool = false
@export var puede_trepar_paredes: bool = true
# --- Muerte ---
signal personaje_muerto
var _muerto: bool
@export var animacion: AnimatedSprite2D
@export var area_2d: Area2D
@export var material_personaje_rojo: ShaderMaterial
func _ready():
	add_to_group("personajes")
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	if ControladorGlobal.tiene_checkpoint:
		global_position = ControladorGlobal.checkpoint
func _on_area_2d_body_entered(_body: Node2D) -> void:
	ControladorGlobal.sumar_muerte()
	animacion.material = material_personaje_rojo
	_muerto = true
	animacion.stop()
	var timer: Timer = Timer.new()
	add_child(timer)
	timer.start(0.2)
	await timer.timeout
	personaje_muerto.emit()
func _physics_process(delta: float) -> void:
	if _muerto:
		return
	walls(delta)
	_jump(delta)
	# --- GRAVEDAD ---
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, FALL_SPEED, GRAVITY * delta)
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME
	# --- MOVIMIENTO HORIZONTAL ---
	var direction = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
	move_and_slide()
	# --- ANIMACIONES ---
	update_animation_and_direction()
func _jump(delta: float) -> void:
	if Input.is_action_just_pressed("saltar"):
		tateobesu = true
	if Input.is_action_just_released("saltar"):
		tateobesu = false
	if is_on_floor() or coyote_timer > 0:
		if tateobesu:
			_saltando_desde_suelo = true
			jump_timer = jump_time_max
			var velocidad_plataforma = 0.0
			for i in get_slide_collision_count():
				var colision = get_slide_collision(i)
				if colision.get_collider() is CharacterBody2D:
					velocidad_plataforma = colision.get_collider().velocity.y
			velocity.y = JUMP_POWER_INITIAL - velocidad_plataforma
			tateobesu = false
			coyote_timer = 0
	elif is_on_wall() and abs(get_wall_normal().x) > 0.9 and !is_on_floor() and puede_trepar_paredes:
		if tateobesu:
			_saltando_desde_suelo = false
			jump_timer = jump_time_max
			velocity.y = JUMP_POWER_INITIAL
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * WALL_JUMP_PUSH
			last_wall = wall_normal
			tateobesu = false
	if Input.is_action_pressed("saltar") and jump_timer > 0:
		velocity.y = move_toward(velocity.y, JUMP_DISTANCE, JUMP_POWER * delta)
		jump_timer -= delta
	else:
		jump_timer = -1
		if Input.is_action_just_released("saltar") and (_saltando_desde_suelo or !is_on_wall()):
			if velocity.y <= 0:
				velocity.y = 0
func walls(delta: float) -> void:
	if !is_on_floor():
		var wall_normal = get_wall_normal()
		if is_on_wall() and velocity.y > 0 and abs(wall_normal.x) > 0.9 and puede_trepar_paredes:
			current_wall_friction += WALL_SLIDE_ACCEL * delta
			velocity.y = min(velocity.y, WALL_SLIDE_START_SPEED + current_wall_friction)
			last_wall = wall_normal
		else:
			current_wall_friction = 0.0
	else:
		current_wall_friction = 0.0
		last_wall = Vector2.ZERO
func update_animation_and_direction() -> void:
	var direction = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	if direction > 0:
		animacion.flip_h = false
	elif direction < 0:
		animacion.flip_h = true
	if is_on_wall() and !is_on_floor() and puede_trepar_paredes:
		var wall_normal = get_wall_normal()
		if wall_normal.x > 0:
			animacion.flip_h = true
		elif wall_normal.x < 0:
			animacion.flip_h = false
		animacion.play("pared")
	elif !is_on_floor():
		animacion.play("saltar-se")
	elif direction != 0:
		animacion.play("correr")
	else:
		animacion.play("idle")
