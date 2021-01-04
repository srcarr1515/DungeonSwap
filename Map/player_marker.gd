## TODO:
## Get the percent diff for 1/2 Viewport and 1/2 Area2d On mini map.
## Get distance_to measurement between player marker and icon (call it obj_dist)
## Spawn Stage Object and move it the obj_dist
## On process when we move along path update obj_dist and move stage obj
## When icon is outside of area2d destroy stage obj

extends KinematicBody2D

var velocity = Vector2.ZERO

export var ACCELERATION = 100
export var MAX_SPEED = 20
export var FRICTION = 400

var current_room
var detected_icons = []
var playerChars = []
var bg_scroller
var floor_scroller
var parallax_bg_scroller
var formation_controller
var input_vector = Vector2.ZERO
var last_state

signal stage_item_in_view(item)
signal stage_item_out_view(item)


func _ready():
	playerChars = get_tree().get_nodes_in_group("player_char")
	bg_scroller = get_tree().get_nodes_in_group("bg_scroller").front()
	floor_scroller = get_tree().get_nodes_in_group("floor").front()
	parallax_bg_scroller = get_tree().get_nodes_in_group("parallax_bg").front()
	formation_controller = get_tree().get_nodes_in_group("formation_controller").front()
	self.connect("stage_item_in_view", formation_controller, "stage_item_in_view")
	self.connect("stage_item_out_view", formation_controller, "stage_item_out_view")

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
			current_room.path_rider.offset += input_vector.x * delta * 50
			var unit_offset = current_room.path_rider.get_unit_offset()
			if unit_offset > 0 && unit_offset < 1:
				var bg_rect = bg_scroller.get_region_rect()
				var floor_rect = floor_scroller.get_region_rect()
				var parallax_rect = parallax_bg_scroller.get_region_rect()
				bg_rect.position.x += input_vector.x * 1.5 * delta * 50
				floor_rect.position.x += input_vector.x * 1.5 * delta * 50
				parallax_rect.position.x += input_vector.x * delta * 5
				bg_scroller.set_region_rect(bg_rect)
				floor_scroller.set_region_rect(floor_rect)
				parallax_bg_scroller.set_region_rect(parallax_rect)
				move_to_path_rider()
				update_stage_obj_x(input_vector.x * 1.5 * delta * 50)

func update_stage_obj_x(input_vector):
	for icon in detected_icons:
		if icon.stageInstance != null:
			icon.set_stage_obj_x(input_vector)


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

func _physics_process(delta):
	move_along_path(delta)

func _on_Area2D_body_entered(body):
	print(body.name)
	## this means it is an icon!
	if "stageObj" in body:
		if body.icon_type != body.icon.ENEMY:
			detected_icons.push_front(body)
			body.mapDist = global_position.x - body.global_position.x
	#		body.mapDist = global_position.distance_to(body.global_position)
			if body.global_position.x < global_position.x:
				body.spawn_side = "left"
			else:
				body.spawn_side = "right"
			print('signal')
			emit_signal("stage_item_in_view", body)

func _on_Area2D_body_exited(body):
	if "stageObj" in body:
		detected_icons.erase(body)
		emit_signal("stage_item_out_view", body)


func _on_TouchRadius_body_entered(body):
	if "stageObj" in body:
		if body.icon_type == body.icon.ENEMY:
			GameState.main_state('battle')
			formation_controller.start_encounter(body.icon_value)
			body.queue_free()

func _on_TouchRadius_body_exited(body):
	pass # Replace with function body.
