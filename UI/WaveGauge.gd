# var level = get_tree().get_nodes_in_group("level").front()
# level.wave_gauge.formation_set.push(["Skeleton_Warrior"])
# level.wave_gauge.timer_set.push([10])
# level.wave_gauge.formation_timer()

extends Node2D

var level
onready var delay_timer = $DelayTimer
var formation_controller
onready var wave_ctr = $WaveCtr_Label
onready var wave_ctr_bg = $WaveCtr_BG
var formation_set = []
var timer_set = []
var cur_index = -1
signal battle_finished

func _ready():
	hide()

func init():
	formation_set = []
	timer_set = []
	cur_index = -1

func formation_timer():
	show()
	cur_index += 1
	## Set counter UI
	if formation_set.size() - cur_index == 0:
		wave_ctr.hide()
		wave_ctr_bg.hide()
	else:
		wave_ctr.show()
		wave_ctr_bg.show()
		wave_ctr.text = String(formation_set.size() - (cur_index))
	if cur_index <= formation_set.size() - 1:
		var timer_amt = timer_set[cur_index]
		if timer_amt == 0:
			var formation = formation_set[cur_index]
			formation_controller.start_encounter(formation)
			formation_timer()
		else:
			delay_timer.start_timer(timer_amt)
	else:
		delay_timer.stop_timer()

func _on_Timer_timeout():
	var formation = formation_set[cur_index]
	formation_controller.start_encounter(formation)
	formation_timer()

func _process(delta):
	if GameState.main == "battle" && cur_index >= formation_set.size():
		var enemies_killed = formation_controller.check_enemies_killed()
		if enemies_killed:
			emit_signal("battle_finished")
			GameState.main_state('map')

func _on_WaveCtr_BG_pressed():
	delay_timer.stop_timer()
	_on_Timer_timeout()
