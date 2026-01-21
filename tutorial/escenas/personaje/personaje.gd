extends CharacterBody2D

const SPEED = 128
const ACCELERATION = 1024
const FALL_SPEED = 500
const GRAVITY = 980

const JUMP_POWER_INITIAL = -250
const JUMP_CUT_MULTIPLIER = 0.1

const PREJUMP_TIME = 0.12
const COYOTE_TIME = 0.10

const WALL_JUMP_PUSH = 128

# Nuevas constantes para wall sliding
const WALL_SLIDE_INITIAL_SPEED = 0  # Velocidad inicial al deslizar
const WALL_SLIDE_MAX_SPEED = 300     # Velocidad máxima al deslizar
const WALL_SLIDE_ACCELERATION = 150  # Qué tan rápido acelera la caída
const WALL_SLIDE_TIMER_MAX = 2.0     # Tiempo para alcanzar velocidad máxima

var prejump_timer := 0.0
var coyote_timer := 0.0
var last_wall: Vector2 = Vector2.ZERO

# Variables para wall sliding
var wall_slide_timer := 0.0  # Tiempo deslizándose en pared
var is_wall_sliding := false # Si está deslizándose

@export var animacion: AnimatedSprite2D

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
		# Girar sprite según dirección de movimiento
		if direction > 0:
			animacion.flip_h = false  # Mira a la derecha
		elif direction < 0:
			animacion.flip_h = true   # Mira a la izquierda
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)

	# --- GRAVEDAD ---
	if !is_on_floor():
		velocity.y = move_toward(velocity.y, FALL_SPEED, GRAVITY * delta)
	else:
		velocity.y = 0
		coyote_timer = COYOTE_TIME  # Reinicia coyote time al tocar suelo
		# Reset timer de wall slide cuando toca suelo
		wall_slide_timer = 0.0
		is_wall_sliding = false

	# --- WALL SLIDING (detectar pared) ---
	wall_sliding()

	# --- CONTROL DE VELOCIDAD EN PARED ---
	if is_wall_sliding:
		# Incrementa el timer mientras esté en la pared
		wall_slide_timer += delta
		
		# Calcula la velocidad de caída basada en el tiempo
		# Usamos una interpolación suave (lerp) desde la velocidad inicial hasta la máxima
		var t = min(wall_slide_timer / WALL_SLIDE_TIMER_MAX, 1.0)
		var target_speed = lerp(WALL_SLIDE_INITIAL_SPEED, WALL_SLIDE_MAX_SPEED, t)
		
		# Limita la velocidad vertical si está cayendo más rápido que la velocidad objetivo
		if velocity.y > target_speed:
			velocity.y = target_speed
		
		# También limita la aceleración de gravedad mientras está en pared
		# Esto hace que la caída sea más controlada
		velocity.y = move_toward(velocity.y, FALL_SPEED, WALL_SLIDE_ACCELERATION * delta)
	else:
		# Reset timer cuando no está en pared
		wall_slide_timer = 0.0

	# --- SALTO (BUFFER + COYOTE + WALL JUMP) ---
	if prejump_timer > 0 and (coyote_timer > 0 or last_wall != Vector2.ZERO):
		_jump()
		prejump_timer = 0
		coyote_timer = 0
		last_wall = Vector2.ZERO
		is_wall_sliding = false
		wall_slide_timer = 0.0

	move_and_slide()
	
	# --- ANIMACIONES Y DIRECCION ---
	update_animation_and_direction()

func update_animation_and_direction():
	if is_wall_sliding:
		# Para wall sliding, giramos el sprite según la dirección de la pared
		if last_wall.x > 0:  # Pared a la derecha (personaje mirando a la izquierda)
			animacion.flip_h = true  # Mira a la izquierda
		elif last_wall.x < 0:  # Pared a la izquierda (personaje mirando a la derecha)
			animacion.flip_h = false  # Mira a la derecha
		animacion.play("pared")  # Necesitarás crear esta animación
	
	elif !is_on_floor():
		# En el aire, mantenemos la dirección horizontal del movimiento
		if velocity.x > 0:
			animacion.flip_h = false  # Mira a la derecha
		elif velocity.x < 0:
			animacion.flip_h = true   # Mira a la izquierda
		# Si no hay movimiento horizontal, mantiene la última dirección
		animacion.play("saltar-se")
	
	elif velocity.x != 0:
		# Ya giramos el sprite en la sección de movimiento horizontal
		animacion.play("correr")
	
	else:
		# En idle, mantiene la última dirección
		animacion.play("idle")

# Detecta si estás tocando una pared y guarda la normal
func wall_sliding():
	if !is_on_floor() and is_on_wall():
		# Verifica que esté presionando hacia la pared
		var wall_normal = get_wall_normal()
		var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		
		# Solo cuenta como wall slide si está presionando hacia la pared
		if (wall_normal.x > 0 and direction < 0) or (wall_normal.x < 0 and direction > 0) or direction == 0:
			last_wall = wall_normal
			is_wall_sliding = true
			return
	
	# Si no cumple las condiciones, no está deslizándose
	is_wall_sliding = false
	if !is_on_wall():
		last_wall = Vector2.ZERO

# Ejecuta salto normal o wall jump
func _jump():
	if last_wall != Vector2.ZERO:
		# Wall jump: salto y empuje lateral
		velocity.y = JUMP_POWER_INITIAL
		velocity.x = last_wall.x * WALL_JUMP_PUSH
		# Giramos el sprite en dirección opuesta a la pared para el wall jump
		if last_wall.x > 0:  # Pared a la derecha
			animacion.flip_h = false  # Mira a la derecha para el salto
		elif last_wall.x < 0:  # Pared a la izquierda
			animacion.flip_h = true   # Mira a la izquierda para el salto
		last_wall = Vector2.ZERO
		is_wall_sliding = false
		wall_slide_timer = 0.0
	else:
		# Salto normal - mantiene la dirección actual
		velocity.y = JUMP_POWER_INITIAL
