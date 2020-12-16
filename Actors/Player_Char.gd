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
onready var act_point = $ActPoint
var is_flipped = false
var atk_power = 1
var atk_anim = null

var battle_role

func _ready():
	## TODO: Need to verify that we actually use atk_power when resolving damage.
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

func detect_target():
	if detect.can_see_target() && battle_role != "support":
		state.state_event({"event": "attack", "target": detect.target})

func move_to(target_pos):
	toggle_flip(global_position > target_pos)
	tween.interpolate_property(self, "global_position", global_position, target_pos, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func AnimAction(args={"end_pos":Vector2(3,0)}):
	var atk_object = null
	if atk_anim != null:
		atk_object = load("res://Actions/{atk_anim}.tscn".format({"atk_anim": atk_anim})).instance()
	if atk_object != null:
		atk_object.atk_power = atk_power
		atk_object.start_pos = act_point.global_position
		atk_object.end_pos = args["end_pos"]
		if is_flipped:
			atk_object.end_pos.x = abs(atk_object.end_pos.x) * -1
		atk_object.spawn()


