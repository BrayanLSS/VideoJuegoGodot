extends KinematicBody2D

export var walk_speed = 9.5
const TILE_SIZE = 16
const MIN_FOLLOW_DISTANCE = TILE_SIZE * 2.5  # Mantener distancia mínima

onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $BlockingRayCast2D

var player_to_follow: KinematicBody2D = null
var is_moving = false
var initial_position = Vector2.ZERO
var input_direction = Vector2.ZERO
var percent_moved_to_next_tile = 0.0
var should_follow = false
var follow_timer = 0.0
const FOLLOW_DELAY = 0.3  # Esperar antes de seguir

func _ready():
	anim_tree.active = false
	$Sprite.visible = false

func start_following(player: KinematicBody2D, start_pos: Vector2):
	player_to_follow = player
	position = snap_to_grid(start_pos)
	initial_position = position
	
	# Conectar señales del jugador
	player_to_follow.connect("player_moving_signal", self, "_on_player_moving")
	player_to_follow.connect("player_stopped_signal", self, "_on_player_stopped")
	
	$Sprite.visible = true
	anim_tree.active = true
	anim_state.travel("Idle")
	print("Dulce iniciada en: ", position)

func snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		round(pos.x / TILE_SIZE) * TILE_SIZE,
		round(pos.y / TILE_SIZE) * TILE_SIZE
	)

func _on_player_moving():
	# Cuando el jugador empieza a moverse, resetear el timer
	follow_timer = 0.0
	should_follow = false

func _on_player_stopped():
	# Cuando el jugador se detiene, activar el timer para seguir
	should_follow = true
	follow_timer = FOLLOW_DELAY

func _physics_process(delta):
	if not anim_tree.active or not player_to_follow:
		return
	
	# Actualizar timer de seguimiento
	if follow_timer > 0:
		follow_timer -= delta
	
	if is_moving:
		move(delta)
	else:
		process_follow_logic()

func process_follow_logic():
	if not player_to_follow:
		return
	
	var distance_to_player = global_position.distance_to(player_to_follow.global_position)
	
	# Solo moverse si:
	# 1. El jugador está lejos (más de MIN_FOLLOW_DISTANCE)
	# 2. El timer de seguimiento terminó
	# 3. La bandera should_follow está activa
	if distance_to_player < MIN_FOLLOW_DISTANCE:
		anim_state.travel("Idle")
		return
	
	# Esperar el delay antes de seguir
	if should_follow and follow_timer > 0:
		anim_state.travel("Idle")
		return
	
	# Si no debemos seguir aún, no hacer nada
	if not should_follow:
		anim_state.travel("Idle")
		return
	
	# Calcular dirección hacia el jugador
	var direction_to_player = player_to_follow.global_position - global_position
	
	# Obtener la mejor dirección cardinal
	var best_direction = get_best_cardinal_direction(direction_to_player)
	
	if best_direction == Vector2.ZERO:
		# No hay dirección válida, esperar
		anim_state.travel("Idle")
		should_follow = false  # Dejar de intentar hasta que el jugador se mueva de nuevo
		return
	
	input_direction = best_direction
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	
	initial_position = position
	is_moving = true

func get_best_cardinal_direction(direction: Vector2) -> Vector2:
	# Normalizar y determinar prioridad
	var abs_x = abs(direction.x)
	var abs_y = abs(direction.y)
	
	var primary_dir = Vector2.ZERO
	var secondary_dir = Vector2.ZERO
	
	# Determinar dirección primaria y secundaria
	if abs_x > abs_y:
		primary_dir = Vector2(sign(direction.x), 0)
		if abs_y > TILE_SIZE * 0.25:  # Solo considerar Y si es significativo
			secondary_dir = Vector2(0, sign(direction.y))
	else:
		primary_dir = Vector2(0, sign(direction.y))
		if abs_x > TILE_SIZE * 0.25:  # Solo considerar X si es significativo
			secondary_dir = Vector2(sign(direction.x), 0)
	
	# Intentar dirección primaria
	if is_direction_clear(primary_dir):
		return primary_dir
	
	# Intentar dirección secundaria
	if secondary_dir != Vector2.ZERO and is_direction_clear(secondary_dir):
		return secondary_dir
	
	# Intentar todas las direcciones cardinales como último recurso
	var all_directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	for dir in all_directions:
		if dir != primary_dir and dir != secondary_dir:
			if is_direction_clear(dir):
				return dir
	
	return Vector2.ZERO

func is_direction_clear(dir: Vector2) -> bool:
	ray.cast_to = dir * TILE_SIZE
	ray.force_raycast_update()
	return not ray.is_colliding()

func move(delta):
	if input_direction == Vector2.ZERO:
		is_moving = false
		return
	
	anim_state.travel("Walk")
	
	var target_position = initial_position + input_direction * TILE_SIZE
	
	# Verificar que el camino sigue libre
	ray.cast_to = input_direction * TILE_SIZE
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		percent_moved_to_next_tile += walk_speed * delta
		
		if percent_moved_to_next_tile >= 1.0:
			position = snap_to_grid(target_position)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			
			# Verificar si ya estamos lo suficientemente cerca
			var distance_to_player = global_position.distance_to(player_to_follow.global_position)
			if distance_to_player < MIN_FOLLOW_DISTANCE:
				should_follow = false  # Dejar de seguir, ya estamos cerca
		else:
			position = initial_position.linear_interpolate(target_position, percent_moved_to_next_tile)
	else:
		# Colisión detectada, detener movimiento
		is_moving = false
		percent_moved_to_next_tile = 0.0
		position = snap_to_grid(position)
		anim_state.travel("Idle")
		
		# Intentar de nuevo después de un momento
		follow_timer = FOLLOW_DELAY