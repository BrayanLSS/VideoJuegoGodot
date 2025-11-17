extends Control

func _ready():
	pass

func _on_IniciarAventura_pressed():
	SceneManager.switch_scene("res://SeleccionPersonaje.tscn")

func _on_Salir_pressed():
	get_tree().quit()
