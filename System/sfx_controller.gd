extends Node2D

func create(sound_file, db):
	var player = AudioStreamPlayer.new()
	self.add_child(player)
	var path = "res://Assets/SFX/{sound_file}"
	player.stream = load(path.format({"sound_file": sound_file}))
	player.set_volume_db(db)
	player.play()
