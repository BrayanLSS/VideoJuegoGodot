extends Node


# Datos del personaje
var personaje_elegido = ""

# Datos para transiciones de escena
var next_scene_spawn_position: Vector2 = Vector2.ZERO
var next_scene_spawn_direction: Vector2 = Vector2.ZERO
var transitioning = false # Para saber si venimos de una transición


func _ready():
	pass # Replace with function body.

func get_player():
	return get_tree().get_root().find_node("Player", true, false)
	
func get_scene_manager():
	return get_tree().get_root().find_node("SceneManager", true, false)
