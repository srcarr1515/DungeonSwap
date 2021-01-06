## TODO:
## Get the percent diff for 1/2 Viewport and 1/2 Area2d On mini map.
## Get distance_to measurement between player marker and icon (call it obj_dist)
## Spawn Stage Object and move it the obj_dist
## On process when we move along path update obj_dist and move stage obj
## When icon is outside of area2d destroy stage obj

extends KinematicBody2D

var velocity = Vector2.ZERO

## am I using these?
export var ACCELERATION = 100
export var MAX_SPEED = 20
export var FRICTION = 400
## 

var scroll_speed = 100
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

func build_in_view():
	var icons = view_area.get_overlapping_bodies()
	for icon in icons:
#		if abs(icon.global_position.x) - abs(global_position.x) < 50:
		if icon.is_in_group("door_icon"):
			if icon.stageObj != null && icon.in_room == current_room.name:
#					detected_icons.push_front(icon)
				var stageObj = icon.stageObj.instance()
				icon.stageInstance = stageObj
				var stageChar = playerVar.get_char_in_slot(5)
				stageObj.global_position = stageChar.global_position
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
			var room = get_parent().get_node(door.icon_value.front().room)
			var exit_door = room.get_node("Icons/Doors/{door}".format({"door": door.icon_value.front().door}))
			var room_path = room.get_node("Path2D")
			## set position of path_rider in new room (to be lined up with you & door)
			room.path_rider.offset = room_path.curve.get_closest_offset(room.to_local(exit_door.global_position))
			## set new room (as current room)
			new_room(room)


func move_raycast():
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
		var state_hash = {
			'-1': "walk",
			'0': "idle",
			'1': "walk"
		}
		toggle_flip(input_vector.x)
		if last_state != state_hash[str(input_vector.x)]:
			update_char_state(state_hash[str(input_vector.x)])
			last_state = state_hash[str(input_vector.x)]
		if current_room != null:
			current_room.path_rider.offset += input_vector.x * delta * scroll_speed
			var unit_offset = current_room.path_rider.get_unit_offset()
			if unit_offset > 0 && unit_offset < 1:
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
	changing_rooms = true
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
	

func _input(event):
	move_raycast()
	if Input.is_action_just_pressed("ui_select"):
		pass

func _physics_process(delta):
	move_along_path(delta)

func _on_Area2D_body_entered(body):
	## this means it is an icon!
	if "stageObj" in body && !changing_rooms:
		if body.in_room == current_room.name:
			print(body.name)
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
			if body.icon_type == body.icon.ENEMY:
				GameState.main_state('battle')
				formation_controller.start_encounter(body.icon_value)
				body.queue_free()

func _on_TouchRadius_body_exited(body):
	pass # Replace with function body.
