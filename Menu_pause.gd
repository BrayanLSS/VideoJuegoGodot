extends CanvasLayer

onready var panel = $Panel

func _ready():
	visible = false  # El menú empieza oculto
	set_process_input(true)  # Escucha teclas

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Tecla Esc
		toggle_pause()

func toggle_pause():
	var tree = get_tree()
	var paused = not tree.paused
	tree.paused = paused
	visible = paused
	# Permitir que el menú funcione mientras el juego está pausado
	pause_mode = Node.PAUSE_MODE_PROCESS
	panel.pause_mode = Node.PAUSE_MODE_PROCESS

func _on_ResumeButton_pressed():
	toggle_pause()

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_MainMenuButton_pressed():
	# Cambia la ruta si tienes una escena principal
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
