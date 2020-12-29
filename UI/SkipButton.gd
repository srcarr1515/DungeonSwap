extends TextureButton

func _on_SkipButton_pressed():
	var formation_controller = get_tree().get_nodes_in_group("formation_controller").front()
	formation_controller.current_wave = 6
	formation_controller._on_Timer_timeout()
