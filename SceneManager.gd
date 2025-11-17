extends Node2D

# Este script ahora solo gestiona las animaciones de transición.
# El cambio de escena real lo hace Godot con get_tree().change_scene().

onready var animation_player = $ScreenTransition/AnimationPlayer
var next_scene_path = ""

func transition_to_scene(path: String):
	# Guarda la ruta de la próxima escena y empieza la animación de salida.
	next_scene_path = path
	animation_player.play("FadeToBlack")

func _on_fade_out_finished():
	# Esta función es llamada por la propia animación "FadeToBlack".
	# Una vez que la pantalla está en negro, cambiamos la escena.
	if next_scene_path != "":
		get_tree().change_scene(next_scene_path)

func switch_scene(path: String):
	# Transición instantánea para UI, sin animación.
	if path != "":
		get_tree().change_scene(path)
