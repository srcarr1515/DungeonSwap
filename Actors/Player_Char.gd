extends KinematicBody2D

var slot_assign = 5
var party_slot
onready var tween = $Tween
onready var sprite = $Sprite
var char_index
onready var state = $FSM
onready var anim_player = $AnimationPlayer
onready var detect = $DetectionZone
onready var stats = $Stats
var is_flipped = false
var atk_power = 1
var atk_anim = null

var battle_role

func _ready():
	pass
#	if sprite.is_flipped_h():
#		detect.radius.global_position = detect.get_node("left_anchor").global_position
#	else:
#		detect.radius.global_position = detect.get_node("right_anchor").global_position

func toggle_flip(flip):
	is_flipped = flip
	if is_flipped:
		scale.x = abs(scale.x) * -1
	else:
		scale.x = abs(scale.x)
#	if flip == null:
#		flip = sprite.is_flipped_h()
#	if sprite.is_flipped_h() != flip:
#		if sprite.offset != Vector2.ZERO:
#			sprite.offset *= -1
#	if flip:
#		sprite.set_flip_h(true)
#		detect.radius.global_position = detect.get_node("left_anchor").global_position
#	else:
#		sprite.set_flip_h(false)
#		detect.radius.global_position = detect.get_node("right_anchor").global_position

func detect_target():
	if detect.can_see_target() && battle_role != "support":
		state.state_event({"event": "attack", "target": detect.target})

func move_to(target_pos):
	toggle_flip(global_position > target_pos)
	tween.interpolate_property(self, "global_position", global_position, target_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


