extends TextureButton

var mode = "pause"


func _on_PauseButton_pressed():
	if mode == "pause":
		## Pause the game
		set_normal_texture(load("res://Assets/Icons/UI/play-button.png"))
		mode = "play"
		get_tree().paused = true
	elif mode == "play":
		## Unpause the game
		set_normal_texture(load("res://Assets/Icons/UI/pause-button.png"))
		mode = "pause"
		get_tree().paused = false
		
