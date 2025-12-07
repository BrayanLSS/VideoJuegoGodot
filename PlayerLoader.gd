extends Node2D

func _ready():
	print("PlayerLoader: Leyendo Utils.personaje_elegido = '", Utils.personaje_elegido, "'")
	
	var character_scenes = {
		"Maggy": "res://Players/Maggy.tscn",
		"Yuli": "res://Players/Yuli.tscn",
		"Edgar": "res://Players/Edgar.tscn",
		"Brayan": "res://Player.tscn",
		"Dulce": "res://Players/Dulce.tscn"
	}
	
	var character_name = Utils.personaje_elegido
	
	if character_name == null or character_name == "":
		character_name = "Brayan"
		print("No se seleccionó personaje, usando por defecto: Brayan")
	
	if not character_scenes.has(character_name):
		print("Error: No se encontró la escena para el personaje: ", character_name)
		character_name = "Brayan"
	
	var character_path = character_scenes[character_name]
	var player_scene = load(character_path)
	
	if player_scene != null:
		var player_instance = player_scene.instance()
		player_instance.name = "Player"
		Utils.player_node = player_instance
		print("DEBUG: Utils.player_node set to: ", Utils.player_node)
		
		var spawn_pos = player_instance.global_position
		if Utils.transitioning and Utils.coming_from_door:
			spawn_pos = Utils.next_scene_spawn_position
		
		player_instance.global_position = spawn_pos
		get_parent().call_deferred("add_child", player_instance)
		print("Personaje '", character_name, "' cargado en la escena.")
		
		# LÓGICA PARA INSTANCIAR A DULCE
		if character_name == "Edgar":
			var dulce_scene = load(character_scenes["Dulce"])
			if dulce_scene:
				var dulce_instance = dulce_scene.instance()
				dulce_instance.name = "DulceFollower"
				
				# Calcular posición inicial de Dulce (2 casillas detrás)
				var dulce_start_pos = spawn_pos + Vector2(0, 32)  # 2 tiles abajo
				dulce_instance.global_position = dulce_start_pos
				
				get_parent().call_deferred("add_child", dulce_instance)
				
				# Esperar a que ambos nodos estén en el árbol antes de conectar
				yield(get_tree(), "idle_frame")
				yield(get_tree(), "idle_frame")
				
				# Iniciar el seguimiento
				dulce_instance.start_following(player_instance, dulce_start_pos)
				print("Dulce configurada para seguir a Edgar desde: ", dulce_start_pos)
			else:
				print("Error al cargar la escena de Dulce.")
	else:
		print("Error al cargar la escena del personaje: ", character_path)
	
	queue_free()