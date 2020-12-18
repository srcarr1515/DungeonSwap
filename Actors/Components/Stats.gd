extends Node

export(int) var max_health = 4
var health = max_health setget set_health

signal no_health
signal health_reduced(value)
signal health_recovered(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	health = max_health
	emit_signal("max_health_changed", value)

func set_health(value):
	if value < health:
		emit_signal("health_reduced", value)
	else:
		emit_signal("health_recovered", value)
	health = value
	if health <= 0:
		health = 0
		emit_signal("no_health")

func _ready():
	self.health = max_health
