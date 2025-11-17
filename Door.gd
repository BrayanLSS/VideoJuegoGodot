extends Area2D

export(String, FILE) var next_scene_path = ""
export(bool) var is_invisible = false

export(Vector2) var spawn_location = Vector2(0, 0)
export(Vector2) var spawn_direction = Vector2(0, 0)

onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer


var player_entered = false

func _ready():
	if is_invisible:
		$Sprite.texture = null
	sprite.visible = false


func _on_Door_body_entered(body):
	player_entered = true


func _on_Door_body_exited(body):
	player_entered = false

func open_door_animation():
	anim_player.play("OpenDoor")
