extends Node2D

const TransitionLayer = preload("res://TransitionLayer.tscn")

var next_scene_path = null
var player_spawn_location = Vector2.ZERO
var player_spawn_direction = Vector2.ZERO
var current_transition_layer = null

var next_scene = null

var player_location = Vector2(0, 0)
var player_direction = Vector2(0, 0)

enum TransitionType { NEW_SCENE, PARTY_SCREEN, MENU_ONLY }
var transition_type = TransitionType.NEW_SCENE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func transition_to_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.PARTY_SCREEN
	
func transition_exit_party_screen():
	$ScreenTransition/AnimationPlayer.play("FadeToBlack")
	transition_type = TransitionType.MENU_ONLY


func transition_to_scene(new_path: String, spawn_location: Vector2, spawn_direction: Vector2):
	if current_transition_layer != null:
		return

	next_scene_path = new_path
	player_spawn_location = spawn_location
	player_spawn_direction = spawn_direction

	current_transition_layer = TransitionLayer.instance()
	current_transition_layer.connect("fade_out_finished", self, "_on_fade_out_finished")
	add_child(current_transition_layer)
	current_transition_layer.fade_out()

func _on_fade_out_finished():
	if $CurrentScene.get_child_count() > 0:
		$CurrentScene.get_child(0).queue_free()

	var new_scene = load(next_scene_path).instance()
	$CurrentScene.add_child(new_scene)

	var player = Utils.get_player()
	if player != null:
		player.set_spawn(player_spawn_location, player_spawn_direction)
	
	if current_transition_layer != null:
		current_transition_layer.fade_in()
	
	current_transition_layer = null
	
func finished_fading():
	match transition_type:
		TransitionType.PARTY_SCREEN:
			$Menu.load_party_screen()
		TransitionType.MENU_ONLY:
			$Menu.unload_party_screen()
	
	$ScreenTransition/AnimationPlayer.play("FadeToNormal")
