extends Node2D

onready var wave_gauge = $WaveGauge
onready var formation_controller = $Player/formation_controller

func _ready():
	wave_gauge.level = self
	wave_gauge.formation_controller = formation_controller
