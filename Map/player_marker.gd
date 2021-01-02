extends KinematicBody2D

var velocity = Vector2.ZERO

export var ACCELERATION = 100
export var MAX_SPEED = 20
export var FRICTION = 400

var current_room

func _ready():
	pass

func move_along_path():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if current_room != null:
		current_room.path_rider.offset += input_vector.x
		move_to_path_rider()

func move_to_path_rider():
	if current_room != null:
		global_position = current_room.path_rider.global_position

func _physics_process(delta):
	move_along_path()
