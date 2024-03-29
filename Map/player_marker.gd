## TODO:
## Get the percent diff for 1/2 Viewport and 1/2 Area2d On mini map.
## Get distance_to measurement between player marker and icon (call it obj_dist)
## Spawn Stage Object and move it the obj_dist
## On process when we move along path update obj_dist and move stage obj
## When icon is outside of area2d destroy stage obj

extends KinematicBody2D

var velocity = Vector2.ZERO

## am I using these?
export var ACCELERATION = 40
export var MAX_SPEED = 20
export var FRICTION = 400
## 

var steps = 0
export var ENCOUNTER_RATE = 96 ## How many steps do you take before we roll for a battle?
export var INIT_ENCOUNTER_PERC = 0.25
var ENCOUNTER_PERC = INIT_ENCOUNTER_PERC ## What is the percent chance of getting into a battle?
var last_battle_time
var last_battle_room

var scroll_speed = 60
var stage_spawner_speed = 1.35 ## controls how fast items spawn into stage (doors, boxes, etc)
## stage_spawner_speed 1.0 == 1x the normal speed.

var current_room
var detected_icons = []
var playerChars = []
var bg_scroller
var floor_scroller
var parallax_bg_scroller
var formation_controller
var input_vector = Vector2.ZERO
var last_state
var changing_rooms = false
var is_blocked = null

onready var view_area = $Area2D
onready var raycast = $RayCast2D
var raycast_dir = "right"

signal stage_item_in_view(item)
signal stage_item_out_view(item)
signal changing_rooms


func _ready():
	playerChars = get_tree().get_nodes_in_group("player_char")
	bg_scroller = get_tree().get_nodes_in_group("bg_scroller").front()
	floor_scroller = get_tree().get_nodes_in_group("floor").front()
	parallax_bg_scroller = get_tree().get_nodes_in_group("parallax_bg").front()
	formation_controller = get_tree().get_nodes_in_group("formation_controller").front()
	self.connect("stage_item_in_view", formation_controller, "stage_item_in_view")
	self.connect("stage_item_out_view", formation_controller, "stage_item_out_view")

func random_encounter():
	var enemy_formation = load("res://Data/enemy_formation.gd").new()
	GameState.main = "event"
	for pc in playerChars:
		pc.state.state_event({"event": "idle"})
		pc.surprise_icon.show()
	yield(get_tree().create_timer(0.7), "timeout")
	for pc in playerChars:
		pc.surprise_icon.hide()
	
	GameState.main_state('battle')
	# Old Code Pre-Wave Based Encounters
	#	formation_controller.start_encounter(formation)
	var level = get_tree().get_nodes_in_group("level").front()
	var wave_ct = Helpers.choose([2,2,2,2,3,3,3,4,4,5]) ## Monkey Patch
	var formation_set = 0
	var formation = []
	level.wave_gauge.init()
	for w in range(wave_ct):
		formation_set = int(rand_range(0,enemy_formation.list.size() - 1))
		formation = enemy_formation.list[formation_set].duplicate(true)
		level.wave_gauge.formation_set.push_back(formation)
		if w == 0:
			## First enemy deployment should happen instantly
			level.wave_gauge.timer_set.push_back(0)
		else:
			level.wave_gauge.timer_set.push_back(Helpers.choose([10, 10, 20, 30]))
	level.wave_gauge.formation_timer()
	yield(level.wave_gauge, "battle_finished")
	last_battle_time = OS.get_ticks_msec()

func roll_for_encounter():
	var roll = rand_range(0.0, 1.0)
	var time_check = true
	var room_check = false
	if last_battle_time != null:
		## We don't want to hit you with back-to-back battles...
		time_check = OS.get_ticks_msec() - last_battle_time > 30000
	if last_battle_room != null:
		room_check = last_battle_room != current_room
	
	if room_check:
		## We are not in the same room since the last encounter roll
		## Increase likelihood of battle
		ENCOUNTER_PERC += 0.15
	
	if roll <= ENCOUNTER_PERC && time_check && INIT_ENCOUNTER_PERC > 0.0:
		ENCOUNTER_PERC = INIT_ENCOUNTER_PERC
		random_encounter()
		last_battle_room = current_room

func build_in_view():
	var icons = view_area.get_overlapping_bodies()
	for icon in icons:
#		if abs(icon.global_position.x) - abs(global_position.x) < 50:
		if icon.is_in_group("map_icon"):
			if icon.stageObj != null && icon.in_room == current_room.name:
#					detected_icons.push_front(icon)
				var stageObj = icon.stageObj.instance()
				icon.stageInstance = stageObj
				var stageChar = playerVar.get_char_in_slot(5)
				stageObj.global_position = stageChar.global_position
				stageObj.map_icon = icon
				stageObj.global_position.y = formation_controller.spawn_right.global_position.y
				ActionController.spawn_instance(stageObj, icon.z_placement)
#				stageObj.sprite.modulate = Color(2,2,1,1)
#					icon.mapDist = global_position.x - icon.global_position.x
#					icon.stageDist = stageChar.global_position.x - stageObj.global_position.x
#					icon.distDiff = (icon.stageDist - icon.mapDist)/icon.mapDist
				# get linear multiplier to scale up icon positioned element
				# so for the full size I will need to move 1/2 of the width of the screen to get to push the object off screen
				# we have the screen width and the collisionshape width... We just need to linear multiplier
				
				var map_distance = global_position.x - icon.global_position.x
				if(abs(map_distance) > 10):
					var stage_size = get_viewport().size
					var minimap_size = view_area.get_node("CollisionShape2D").shape.extents.x * 0.72
					var size_diff = ((stage_size.x - minimap_size)/minimap_size) + 1.0 ## percent change
					stageObj.global_position.x -= (size_diff * map_distance)/2
				if icon.z_placement == "FG":
					stageObj.set_fg_element()
#				print(icon,' name:', icon.name, " icon stage: ", icon.stageInstance.name)

func set_raycast_dir(new_dir):
	var prev_dir = raycast_dir
	var use_door = false
	raycast_dir = new_dir
	if prev_dir != new_dir:
		match raycast_dir:
				"up":
					raycast.global_rotation_degrees = 270
				"down":
					raycast.global_rotation_degrees = 90
				"left":
					raycast.global_rotation_degrees = 180
				"right":
					raycast.global_rotation_degrees = 0
				
		yield(get_tree().create_timer(0.1), "timeout")
		var collider = raycast.get_collider()
		var highlighters = get_tree().get_nodes_in_group("highlighter")
		for highlight in highlighters:
			highlight.hide()
		if collider != null:
			var door = collider.get_parent()
			if door.stageInstance != null:
				door.stageInstance.set_focus(true)
	elif prev_dir == new_dir:
		use_door = new_dir in ["up", "down"]
		if !use_door:
			var unit_offset = current_room.path_rider.get_unit_offset()
			if unit_offset == 0 && new_dir == "left": 
				use_door = true
			elif unit_offset == 1 && new_dir == "right":
				use_door = true
	if use_door:
		var collider = raycast.get_collider()
		if collider != null:
			var door = collider.get_parent()
			door.use_door()
#			var room = get_parent().get_node(door.icon_value.front().room)
#			var exit_door = room.get_node("Icons/Doors/{door}".format({"door": door.icon_value.front().door}))
#			var room_path = room.get_node("Path2D")
#			## set position of path_rider in new room (to be lined up with you & door)
#			room.path_rider.offset = room_path.curve.get_closest_offset(room.to_local(exit_door.global_position))
#			## set new room (as current room)
#			new_room(room)

func move_raycast():
	if GameState.main != "battle":
		raycast.set_enabled(true)
		var prev_dir = raycast_dir
		if Input.is_action_just_pressed("ui_up"):
			set_raycast_dir("up")
		elif Input.is_action_just_pressed("ui_down"):
			set_raycast_dir("down")
		elif Input.is_action_just_pressed("ui_left"):
			set_raycast_dir("left")
		elif Input.is_action_just_pressed("ui_right"):
			set_raycast_dir("right")

func move_along_path(delta):
	if GameState.main == "map":
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		if input_vector.x != 0:
			if current_room != null && is_blocked != input_vector.x:
				current_room.path_rider.offset += input_vector.x * delta * scroll_speed
				var unit_offset = current_room.path_rider.get_unit_offset()
				if unit_offset > 0 && unit_offset < 1:
					## Keep track of steps and checks for encounter every so many steps.
					steps += 1
					if steps % ENCOUNTER_RATE == 0:
						roll_for_encounter()
					## BG, Floor Elements
					var bg_rect = bg_scroller.get_region_rect()
					var floor_rect = floor_scroller.get_region_rect()
					var parallax_rect = parallax_bg_scroller.get_region_rect()
					bg_rect.position.x += input_vector.x * stage_spawner_speed * delta * scroll_speed
					floor_rect.position.x += input_vector.x * stage_spawner_speed * delta * scroll_speed
					parallax_rect.position.x += input_vector.x * delta * scroll_speed / 10
					bg_scroller.set_region_rect(bg_rect)
					floor_scroller.set_region_rect(floor_rect)
					parallax_bg_scroller.set_region_rect(parallax_rect)
					move_to_path_rider()
					update_stage_obj_x(input_vector.x * stage_spawner_speed * delta * scroll_speed)

		var state_hash = {
				'-1': "walk",
				'0': "idle",
				'1': "walk"
			}
		toggle_flip(input_vector.x)
		if last_state != state_hash[str(input_vector.x)]:
			update_char_state(state_hash[str(input_vector.x)])
			last_state = state_hash[str(input_vector.x)]

func update_stage_obj_x(input_vector):
	## old way ... buggy... still may want to go down this path...
#	for icon in detected_icons:
#		if icon.stageInstance != null:
#			icon.set_stage_obj_x(input_vector)
	var stage_objects = get_tree().get_nodes_in_group("stage_object")
	for obj in stage_objects:
		obj.global_position.x -= input_vector


func toggle_flip(input_vec):
	if input_vec != 0:
		var flip_hash = {
			'-1': true,
			'1': false
		}
		for pc in playerChars:
			pc.toggle_flip(flip_hash[str(input_vec)])

func update_char_state(state_event):
	for pc in playerChars:
			if pc.state.current != state_event:
				pc.state.state_event({"event": state_event})

func update_stage_obj_pos():
	for icon in detected_icons:
		var dist = global_position.x - icon.global_position.x
#		var dist = global_position.distance_to(icon.global_position)
		icon.set_stage_obj_pos(dist)

func move_to_path_rider():
	if current_room != null:
		global_position = current_room.path_rider.global_position

func new_room(room):
	ENCOUNTER_PERC += 0.05
	changing_rooms = true
	GameState.main = "event"
	var camera = get_tree().get_nodes_in_group("main_camera").front()
	var fader = camera.get_node("ScreenFade")
	fader.fade_type = fader.fade.IN
	fader.duration = 0.5
	fader.start_fade()
	yield(fader.tween, "tween_completed")
	current_room = room
	move_to_path_rider()
	var stage_objects = get_tree().get_nodes_in_group("stage_object")
	for obj in stage_objects:
		obj.queue_free()
	yield(get_tree().create_timer(0.1), "timeout")
	build_in_view()
	fader.fade_type = fader.fade.OUT
	fader.duration = 0.4
	fader.start_fade()
	changing_rooms = false
	GameState.main = "map"


func _input(event):
	move_raycast()
	if Input.is_action_just_pressed("ui_select"):
		pass

func _physics_process(delta):
	move_along_path(delta)

func _on_Area2D_body_entered(body):
	## this means it is an icon!
	if "stageObj" in body && !changing_rooms:
		if body.in_room == null:
			print("room not set!")
		if body.in_room == current_room.name:
			if body.reveal_when_found:
				body.show()
			if body.icon_type != body.icon.ENEMY:
				detected_icons.push_front(body)
				body.mapDist = global_position.x - body.global_position.x
		#		body.mapDist = global_position.distance_to(body.global_position)
				if body.global_position.x < global_position.x:
					body.spawn_side = "left"
				else:
					body.spawn_side = "right"
				emit_signal("stage_item_in_view", body)

func _on_Area2D_body_exited(body):
	if "stageObj" in body && !changing_rooms:
		detected_icons.erase(body)
		emit_signal("stage_item_out_view", body)


func _on_TouchRadius_body_entered(body):
	if "stageObj" in body:
		if body.in_room == current_room.name:
			if body.is_solid:
				if body.global_position.x > global_position.x:
					is_blocked = 1
				else:
					is_blocked = -1
			if body.touch_trigger != body.trigger.NONE:
				if body.touch_trigger_anim != null:
					body.stageInstance.get_node("AnimationPlayer").play(body.touch_trigger_anim)
			if body.touch_trigger != body.trigger.NONE:
				body.trigger(body.touch_trigger, body.touch_trigger_target)
				body.touch_trigger_target = null
				body.touch_trigger = body.trigger.NONE
				
#				if body.touch_trigger_target != null:
#					## Monkey Patch Until We Make Event System:
#					GameState.main = "event"
#					var map = get_parent()
#					map.camera_speed = 0.02
#					map.camera_target = body.touch_trigger_target
#					yield(map, "camera_move_completed")
#					###
#					body.touch_trigger_target.queue_free()
#					body.touch_trigger_target = null
#					body.touch_trigger = body.trigger.NONE
#					map.camera_speed = 0.0
#					map.camera_target = self
#					yield(get_tree().create_timer(1), "timeout")
#					GameState.main = "map"
#					map.camera_speed = 0.2
			if body.icon_type == body.icon.ENEMY:
#				surprise_icon.hide()
				GameState.main = "event"
				for pc in playerChars:
					pc.state.state_event({"event": "idle"})
					pc.surprise_icon.show()
				yield(get_tree().create_timer(0.7), "timeout")
				for pc in playerChars:
					pc.surprise_icon.hide()
				
				## Monkey Patch
				var text = "Foolish Mortal..."
				text += "\n\nShane doesn't have time to make you a boss fight, he's got kids son. "
				text += "Here's a bunch of waves to keep you busy in the mean time."
				ActionController.create_msg(text)
				yield(GameState.parent, 'left_mouse')
				GameState.main_state('battle')
				var enemy_formation = load("res://Data/enemy_formation.gd").new()
				var level = get_tree().get_nodes_in_group("level").front()
				level.wave_gauge.init()
				level.wave_gauge.formation_set.push_back(enemy_formation.list[2].duplicate(true))
				level.wave_gauge.timer_set.push_back(0)
				
				for n in range(4):
					level.wave_gauge.formation_set.push_back(enemy_formation.list[3].duplicate(true))
					level.wave_gauge.timer_set.push_back(Helpers.choose([10,10,20,30]))
					level.wave_gauge.formation_set.push_back(enemy_formation.list[6].duplicate(true))
					level.wave_gauge.timer_set.push_back(Helpers.choose([10,10,20,30]))
					level.wave_gauge.formation_set.push_back(enemy_formation.list[7].duplicate(true))
					level.wave_gauge.timer_set.push_back(Helpers.choose([10,10,20,30]))
				

				
				level.wave_gauge.formation_timer()

				## old code:
				# formation_controller.start_encounter(body.icon_value)
				body.queue_free()

func _on_TouchRadius_body_exited(body):
	if "stageObj" in body:
		if body.is_solid:
			is_blocked = null
