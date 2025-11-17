extends Control

onready var etiqueta_personaje = $VBoxContainer/SelectedCharacterLabel
onready var boton_confirmar = $VBoxContainer/ActionButtons/BotonConfirmar

# Esta variable guardará el personaje seleccionado.
# Usaremos un string por ahora: "Maggy", "Yuli", "Brayan", "Edgar"
var personaje_seleccionado = ""

func _ready():
	# Asegurarse de que la etiqueta esté vacía al inicio
	etiqueta_personaje.text = ""

func _on_personaje_selected(nombre_personaje):
	personaje_seleccionado = nombre_personaje
	etiqueta_personaje.text = "Personaje: " + personaje_seleccionado
	# Activar el botón de confirmar una vez que se ha hecho una selección
	boton_confirmar.disabled = false

func _on_BotonAtras_pressed():
	get_tree().change_scene("res://MenuPrincipal.tscn")

func _on_BotonConfirmar_pressed():
	if personaje_seleccionado == "":
		print("Ningun personaje seleccionado!")
		return
	
	# Guardar la elección en el script global (autoload)
	Utils.personaje_elegido = personaje_seleccionado
	
	print("Confirmado: ", Utils.personaje_elegido, ". Cargando juego...")
	
	# Cambiar a la escena del juego. Usamos Town.tscn como el mapa principal por ahora.
	SceneManager.transition_to_scene("res://Town.tscn")
