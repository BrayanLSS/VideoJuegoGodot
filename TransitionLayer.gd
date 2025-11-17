extends CanvasLayer

signal fade_out_finished

onready var animation_player = $AnimationPlayer

func fade_in():
	animation_player.play("fade_in")

func fade_out():
	animation_player.play("fade_out")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_out":
		emit_signal("fade_out_finished")
	elif anim_name == "fade_in":
		queue_free()
