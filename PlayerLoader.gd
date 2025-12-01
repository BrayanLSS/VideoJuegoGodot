extends Node2D

func _ready():
	print("PlayerLoader: Leyendo Utils.personaje_elegido = '", Utils.personaje_elegido, "'")
	# Diccionario que mapea el nombre del personaje a la ruta de su escena
	var character_scenes = {
		"Maggy": "res://players/Maggy.tscn",
		"Yuli": "res://players/Yuli.tscn",
		"Edgar": "res://players/Edgar.tscn",
		"Brayan": "res://Player.tscn"  # Asumimos que Player.tscn es Brayan
	}
	
	var character_name = Utils.personaje_elegido
	
	# Si no se eligió ningún personaje (ej. al correr el juego directamente),
	# usamos uno por defecto.
	if character_name == null or character_name == "":
		character_name = "Brayan"
		print("No se seleccionó personaje, usando por defecto: Brayan")

	# Verificar si el personaje seleccionado tiene una escena definida
	if not character_scenes.has(character_name):
		print("Error: No se encontró la escena para el personaje: ", character_name)
		# Cargar el personaje por defecto como fallback
		character_name = "Brayan"

	# Cargar, instanciar y añadir el personaje a la escena
	var character_path = character_scenes[character_name]
	var player_scene = load(character_path)
	
	if player_scene != null:
		var player_instance = player_scene.instance()
		player_instance.name = "Player" # Nombre consistente para el nodo
		Utils.player_node = player_instance # Asignar la referencia directa
		
		# Si hay una posición de spawn definida desde una puerta, la usamos
		if Utils.transitioning and Utils.coming_from_door:
			player_instance.global_position = Utils.next_scene_spawn_position
		
		# Añadimos el jugador a la escena principal (padre del PlayerLoader) de forma segura
		get_parent().call_deferred("add_child", player_instance)
		print("Personaje '", character_name, "' cargado en la escena.")
	else:
		print("Error al cargar la escena del personaje: ", character_path)

	# Una vez que el cargador ha hecho su trabajo, se elimina a sí mismo.
	queue_free()