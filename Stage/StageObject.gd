extends StaticBody2D

onready var sprite = $Sprite

func blur(amount=1):
	sprite.get_material().set_shader_param("radius", amount)

func set_fg_element():
	sprite.set_scale(Vector2(1.1,1.1))
	blur()


