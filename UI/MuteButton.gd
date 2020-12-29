extends TextureButton

var mode = "play"

func _on_MuteButton_pressed():
	if mode == "mute":
		set_normal_texture(load("res://Assets/Icons/UI/speaker.png"))
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		mode = "play"
	elif mode == "play":
		set_normal_texture(load("res://Assets/Icons/UI/speaker-off.png"))
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		mode = "mute"
