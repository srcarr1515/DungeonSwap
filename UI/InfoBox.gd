extends Node2D

onready var header = $header
onready var body = $body
onready var start_position = global_position

func _ready():
	hide()
