extends Node

func _ready():
	pass # Replace with function body.

func post_effects():
	print('after')

func pre_effects():
	print('before')
	return false
