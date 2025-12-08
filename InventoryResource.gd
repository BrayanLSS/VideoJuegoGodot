extends Resource

class_name InventoryResource

export var items = []

func add_item(item, quantity: int):
	for slot_data in items:
		if slot_data.item == item and slot_data.item.stackable:
			slot_data.quantity += quantity
			return

	var new_slot_data = InventorySlotData.new()
	new_slot_data.item = item
	new_slot_data.quantity = quantity
	items.append(new_slot_data)
