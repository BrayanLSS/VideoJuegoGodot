extends Control

# Referencias a los nodos
var video_player: VideoPlayer
var audio_player: AudioStreamPlayer

func _ready():
	# Configurar el video de fondo
	setup_background_video()
	# Configurar la música
	setup_background_music()

func setup_background_video():
	# Crear el VideoPlayer
	video_player = VideoPlayer.new()
	
	# Cargar el video
	var video_stream = load("res://Video/uni_explore.mp4")
	if not video_stream:
		print("No se pudo cargar el video 'res://Video/uni_explore.mp4'. Asegúrate de que el archivo exista y haya sido importado correctamente como VideoStream en el editor de Godot.")
		return
	video_player.stream = video_stream
	
	# Conectar la señal 'finished' para crear un bucle
	video_player.connect("finished", self, "_on_VideoPlayer_finished")
	
	# Configurar propiedades del video
	video_player.expand = true
	video_player.autoplay = true
	video_player.volume_db = -80  # Silenciar el video
	
	# Añadir como primer hijo para que esté detrás de todo
	add_child(video_player)
	move_child(video_player, 0)
	
	# Ajustar el tamaño al viewport
	video_player.anchor_right = 1.0
	video_player.anchor_bottom = 1.0

func setup_background_music():
	# Crear el AudioStreamPlayer
	audio_player = AudioStreamPlayer.new()
	
	# Cargar la música
	var music = load("res://Audio/Weatherfall (Hyper Potions Remix).mp3")
	if not music:
		print("No se pudo cargar la música 'res://Audio/Weatherfall (Hyper Potions Remix).mp3'. Asegúrate de que el archivo exista y esté importado.")
		return
	audio_player.stream = music
	
	# Configurar propiedades del audio
	audio_player.autoplay = true
	
	# Añadir al árbol de nodos
	add_child(audio_player)

func _on_VideoPlayer_finished():
	video_player.play()

func _on_IniciarAventura_pressed():
	# Detener la música al cambiar de escena
	if audio_player:
		audio_player.stop()
	SceneManager.switch_scene("res://SeleccionPersonaje.tscn")

func _on_Salir_pressed():
	get_tree().quit()

func _exit_tree():
	if audio_player and audio_player.playing:
		audio_player.stop()