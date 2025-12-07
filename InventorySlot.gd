extends Panel

@onready var texture_rect = $TextureRect
@onready var label = $Label

func set_item(item_texture: Texture, quantity: int):
	texture_rect.texture = item_texture
	label.text = str(quantity)
	if quantity > 1:
		label.show()
	else:
		label.hide()

func clear():
	texture_rect.texture = null
	label.hide()
