extends Node2D

@export var item: Item
@onready var sprite = $Sprite2D

func _ready():
	if item:
		sprite.texture = item.texture

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		var player_inventory = body.inventory
		player_inventory.add_item(item, 1)
		queue_free()
