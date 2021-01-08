extends Node2D

#onready var camera = $ViewportContainer/Viewport/Camera2D
onready var player = $ViewportContainer/Viewport/Map/player_marker
onready var map = $ViewportContainer/Viewport/Map

func _ready():
	pass
#	print(camera.global_position)
#	camera.global_postion = player.global_position


func _on_Zoom_In_button_down():
	var next_zoom = map.camera.get_zoom() * 0.9
	map.camera.set_zoom(next_zoom)

func _on_Zoom_Out_button_down():
	var next_zoom = map.camera.get_zoom() * 1.1
	map.camera.set_zoom(next_zoom)
