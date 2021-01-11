extends StaticBody2D

onready var sprite = $Sprite
onready var highlighter = $Highlighter
onready var anim_player = $AnimationPlayer
export (Texture) var highlighter_default
export (String) var start_animation
onready var white_shader = preload("res://Effects/WhiteCover.tres")
var map_icon
var is_selected = false
var player_range =  65

func _ready():
	if map_icon.override_start_anim != null:
		start_animation = map_icon.override_start_anim
	if start_animation != null:
		anim_player.play(start_animation)
	set_focus(false)
	highlighter.set_material(white_shader)
	highlighter.material.set_shader_param("flash_modifier", 1)
	highlighter.material.set_shader_param("flash_color", Color(1,1,1,1))

func blur(amount=1):
	sprite.get_material().set_shader_param("radius", amount)

func set_fg_element():
	sprite.set_scale(Vector2(1.1,1.1))
	blur()

func set_focus(is_focus):
	if highlighter_default == null:
		highlighter.set_texture(sprite.get_texture())
		highlighter.set_scale(sprite.get_scale() * 1.05)
		highlighter.position = sprite.position
		highlighter.rotation_degrees = sprite.rotation_degrees
		## check if animated
		if sprite.get_vframes() > 0:
			highlighter.set_vframes(sprite.get_vframes())
			highlighter.set_hframes(sprite.get_hframes())
			highlighter.set_frame(sprite.get_frame())
	else:
		highlighter.set_texture(highlighter_default)
	
	if is_focus:
		highlighter.show()
	else:
		highlighter.hide()

func _input(event):
	if Input.is_action_just_pressed("left_mouse") && GameState.main == "map":
		if map_icon.dist_to_player() < player_range && is_selected:
			highlighter.hide()
			if map_icon.act_trigger_anim != null:
				anim_player.play(map_icon.act_trigger_anim)
			if map_icon.act_trigger != map_icon.trigger.NONE:
				map_icon.trigger(map_icon.act_trigger, map_icon.act_trigger_target)
			if !map_icon.persist_act_trigger:
				map_icon.act_trigger_target = null
				map_icon.act_trigger_anim = null
				map_icon.act_trigger = map_icon.trigger.NONE
			
func _on_StageObject_mouse_entered():
	set_focus(true)
	if map_icon.dist_to_player() <= player_range:
		highlighter.material.set_shader_param("flash_color", Color(1,1,1,1))
		highlighter.modulate = Color(1,1,1,1)
	else:
		highlighter.material.set_shader_param("flash_color", Color(1,0,0,1))
		highlighter.modulate = Color(1,1,1,0.2)
	is_selected = true

func _on_StageObject_mouse_exited():
	set_focus(false)
	is_selected = false

func call_map_method(method_name, params=[]):
	map_icon.map.callv(method_name, params)

func call_action_controller(method_name, params=[]):
	ActionController.callv(method_name, params)

func set_start_anim(anim):
	map_icon.override_start_anim = anim
