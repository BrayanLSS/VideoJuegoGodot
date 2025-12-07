extends KinematicBody2D

signal player_moving_signal
signal player_stopped_signal

signal player_entering_door_signal
signal player_entered_door_signal

const LandingDustEffect = preload("res://LandingDustEffect.tscn")

export var walk_speed = 10.0
export var jump_speed = 4.0
const TILE_SIZE = 16

onready var anim_tree = $AnimationTree
onready var anim_state = anim_tree.get("parameters/playback")
onready var ray = $BlockingRayCast2D
onready var ledge_ray = $LedgeRayCast2D
onready var door_ray = $DoorRayCast2D
onready var tween = $Tween

onready var shadow = $Shadow
var jumping_over_ledge: bool = false

enum PlayerState { IDLE, TURNING, WALKING }
enum FacingDirection { LEFT, RIGHT, UP, DOWN }

var player_state = PlayerState.IDLE
var facing_direction = FacingDirection.DOWN

var initial_position = Vector2(0, 0)
var input_direction = Vector2(0, 1)
var is_moving = false
var stop_input: bool = false
var percent_moved_to_next_tile = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.visible = true
	anim_tree.active = true
	initial_position = position
	shadow.visible = false
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)

	if Utils.transitioning:
		Utils.transitioning = false
		play_exit_animation()

func set_spawn(location: Vector2, direction: Vector2):
	anim_tree.set("parameters/Idle/blend_position", direction)
	anim_tree.set("parameters/Walk/blend_position", direction)
	anim_tree.set("parameters/Turn/blend_position", direction)
	position = location

func _physics_process(delta):
	if not anim_tree.active:
		return

	if player_state == PlayerState.TURNING or stop_input:
		return
	elif is_moving == false:
		process_player_movement_input()
	elif input_direction != Vector2.ZERO:
		anim_state.travel("Walk")
		move(delta)
	else:
		anim_state.travel("Idle")
		is_moving = false

func process_player_movement_input():
	var new_input_direction = Vector2.ZERO
	new_input_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	if new_input_direction.x == 0:
		new_input_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))

	input_direction = new_input_direction

	if input_direction != Vector2.ZERO:
		anim_tree.set("parameters/Idle/blend_position", input_direction)
		anim_tree.set("parameters/Walk/blend_position", input_direction)
		anim_tree.set("parameters/Turn/blend_position", input_direction)

		#if need_to_turn():
		#	player_state = PlayerState.TURNING
		#	anim_state.travel("Turn")
		#else:
		initial_position = position
		is_moving = true
	else:
		anim_state.travel("Idle")

func need_to_turn():
	var new_facing_direction
	if input_direction.x < 0:
		new_facing_direction = FacingDirection.LEFT
	elif input_direction.x > 0:
		new_facing_direction = FacingDirection.RIGHT
	elif input_direction.y < 0:
		new_facing_direction = FacingDirection.UP
	elif input_direction.y > 0:
		new_facing_direction = FacingDirection.DOWN

	if facing_direction != new_facing_direction:
		facing_direction = new_facing_direction
		return true
	facing_direction = new_facing_direction
	return false

func finished_turning():
	player_state = PlayerState.IDLE

func entered_door():
	emit_signal("player_entered_door_signal")

func move(delta):
	var desired_step: Vector2 = input_direction * TILE_SIZE / 2
	ray.cast_to = desired_step
	ray.force_raycast_update()

	ledge_ray.cast_to = desired_step
	ledge_ray.force_raycast_update()

	door_ray.cast_to = desired_step
	door_ray.force_raycast_update()

	if door_ray.is_colliding():
		var door = door_ray.get_collider()
		if door and "next_scene_path" in door:
			is_moving = false
			stop_input = true
			enter_door_animation(door)
			return # Stop processing movement further

	elif (ledge_ray.is_colliding() && input_direction == Vector2(0, 1)) or jumping_over_ledge:
		percent_moved_to_next_tile += jump_speed * delta
		if percent_moved_to_next_tile >= 2.0:
			position = initial_position + (input_direction * TILE_SIZE * 2)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			jumping_over_ledge = false
			shadow.visible = false

			var dust_effect = LandingDustEffect.instance()
			dust_effect.position = position
			get_tree().current_scene.add_child(dust_effect)

		else:
			shadow.visible = true
			jumping_over_ledge = true
			var input = input_direction.y * TILE_SIZE * percent_moved_to_next_tile
			position.y = initial_position.y + (-0.96 - 0.53 * input + 0.05 * pow(input, 2))

	elif !ray.is_colliding():
		if percent_moved_to_next_tile == 0:
			emit_signal("player_moving_signal")
		percent_moved_to_next_tile += walk_speed * delta
		if percent_moved_to_next_tile >= 1.0:
			position = initial_position + (input_direction * TILE_SIZE)
			percent_moved_to_next_tile = 0.0
			is_moving = false
			emit_signal("player_stopped_signal")
		else:
			position = initial_position + (input_direction * TILE_SIZE * percent_moved_to_next_tile)
	else:
		is_moving = false

func enter_door_animation(door):
	# Primero hacer que el jugador camine hacia la puerta
	anim_state.travel("Walk")
	tween.remove_all()
	
	var move_to = position + input_direction * TILE_SIZE
	tween.interpolate_property(self, "position", position, move_to, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	# Esperar a que termine el movimiento
	yield(get_tree().create_timer(0.3), "timeout")
	
	# Ocultar el sprite
	$Sprite.visible = false
	anim_state.travel("Idle")
	
	# Guardar información para la siguiente escena
	Utils.next_scene_spawn_position = door.spawn_location
	Utils.next_scene_spawn_direction = door.spawn_direction
	Utils.transitioning = true
	Utils.coming_from_door = true
	
	# Iniciar la transición de escena
	var scene_manager = Utils.get_scene_manager()
	scene_manager.transition_to_scene(door.next_scene_path)


var inventory = preload("res://PlayerInventory.tres")

onready var inventory_ui = get_node("/root/Town/UI/Inventory")

func _unhandled_input(event):
	if event.is_action_pressed("ui_inventory"):
		inventory_ui.toggle()


func play_exit_animation():
	var scene_manager = Utils.get_scene_manager()
	
	# Posicionar al jugador en el punto de spawn
	if Utils.coming_from_door:
		position = Utils.next_scene_spawn_position
		input_direction = Utils.next_scene_spawn_direction

		if input_direction.x < 0:
			facing_direction = FacingDirection.LEFT
		elif input_direction.x > 0:
			facing_direction = FacingDirection.RIGHT
		elif input_direction.y < 0:
			facing_direction = FacingDirection.UP
		elif input_direction.y > 0:
			facing_direction = FacingDirection.DOWN
		
	anim_tree.set("parameters/Idle/blend_position", input_direction)
	anim_tree.set("parameters/Walk/blend_position", input_direction)
	anim_tree.set("parameters/Turn/blend_position", input_direction)
	
	# Asegurarse de que el sprite esté visible
	$Sprite.visible = true
	
	# Iniciar FadeIn (de negro a transparente)
	scene_manager.animation_player.play("FadeToNormal")
	
	# After fade-in, the player should be able to move.
	# The "FadeToNormal" animation is 1 second long.
	yield(get_tree().create_timer(1.0), "timeout")

	anim_state.travel("Idle")
	stop_input = false
	input_direction = Vector2.ZERO
