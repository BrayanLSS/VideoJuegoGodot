extends Control

export(Resource) var inventory_data
onready var grid_container = $NinePatchRect/GridContainer

func _ready():
	hide()

func toggle():
	if visible:
		hide()
	else:
		update_slots()
		show()

func update_slots():
	var slots = grid_container.get_children()
	for i in range(slots.size()):
		if i < inventory_data.items.size():
			var slot_data = inventory_data.items[i]
			slots[i].set_item(slot_data.item.texture, slot_data.quantity)
		else:
			slots[i].clear()
