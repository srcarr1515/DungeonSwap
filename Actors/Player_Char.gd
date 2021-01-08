extends KinematicBody2D

var slot_assign = 5 ## The slot (in level)
var party_slot
onready var tween = $Tween
onready var sprite = $Sprite
var char_index
onready var state = $FSM
onready var anim_player = $AnimationPlayer
onready var detect = $DetectionZone
onready var stats = $Stats
onready var act_point = $ActPoint
onready var health_display = $HealthDisplay
onready var delay_timer = $DelayTimer
onready var surprise_icon = $surprise_icon

var is_flipped = false
var atk_power = 1
var atk_anim = null

var battle_role
var attack_queue = []
var has_target = false

func _ready():
	## TODO: Need to verify that we actually use atk_power when resolving damage.
	surprise_icon.hide()
	health_display.init()
	health_display.set_scale(Vector2(0.1, 0.1))
	health_display.global_position = global_position - Vector2(0,10)
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

func resolveAttack():
	pass
#	var attack_target = attack_queue.front()
#	if attack_target != null && attack_queue.size() > 0:
#		if is_instance_valid(attack_target) && "stats" in attack_target:
#			attack_target.stats.health -= atk_power
#			if attack_target == null || attack_target.stats.health < 1:
#				attack_queue.pop_front()

func AnimAction(args={"end_pos":Vector2(3,0)}):
	var atk_object = null
	if atk_anim != null:
		args["start_pos"] = act_point.global_position
		args["action_owner"] = self
		args["atk_power"] = atk_power
		if is_flipped:
			args["is_flipped"] = true
		ActionController.spawn_action(atk_anim, args)

func _on_HurtBox_area_entered(area):
	if !get_tree().get_nodes_in_group("game_base").front().cheat_modes.has("God Mode"):
		var entity = area.get_parent()
		if entity.is_in_group("enemy") && area.name == "HitBox":
			if state.current == "death":
				var chars = get_tree().get_nodes_in_group("player_char")
				for c in chars:
					if c.slot_assign == 5 && c.state.current != "death":
						c._on_HurtBox_area_entered(area)
					elif c.slot_assign != slot_assign && c.state.current != "death":
						c._on_HurtBox_area_entered(area)
			else:
				stats.health -= entity.atk_power
				if stats.health < 1:
					var enemies = get_tree().get_nodes_in_group("enemy")
					for enemy in enemies:
						if "playerDetect" in enemy:
							if enemy.playerDetect.target == self:
								enemy.playerDetect.target = null
					state.state_event({"event": "death"})
