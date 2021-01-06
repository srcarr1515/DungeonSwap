extends StaticBody2D

onready var sprite = $Sprite
onready var highlighter = $Highlighter

func _ready():
	set_focus(false)

func blur(amount=1):
	sprite.get_material().set_shader_param("radius", amount)

func set_fg_element():
	sprite.set_scale(Vector2(1.1,1.1))
	blur()

func set_focus(is_focus):
	highlighter.set_texture(sprite.get_texture())
	highlighter.set_scale(sprite.get_scale() * 1.05)
	highlighter.position = sprite.position
	if is_focus:
		highlighter.show()
	else:
		highlighter.hide()


