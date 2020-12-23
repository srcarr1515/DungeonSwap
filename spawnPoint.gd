extends Position2D

onready var timer = $Timer
var avail_enemies = ["Wolf", "Skeleton_Warrior"]
var formation = []
var timer_amt = 1
export var deployment_group = "left_side_enemy"

signal deploy_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
#	while formation.size() < 8:
#		var random_index = floor(rand_range(0, avail_enemies.size()))
#		var enemy = avail_enemies[random_index]
#		formation.push_front(enemy)
#	reset_timer()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reset_timer():
	timer.start(timer_amt)

func _on_Timer_timeout():
	if formation.size() > 0:
		spawnEnemy(formation.front())
		formation.pop_front()
	else:
		timer.stop()
		emit_signal("deploy_finished")

func spawnEnemy(enemy_name):
	if enemy_name != null:
		var actor_path = "res://Actors/Enemy/{enemy_name}.tscn"
		var enemy = load(actor_path.format({"enemy_name": enemy_name})).instance()
		enemy.add_to_group(deployment_group)
		add_child(enemy)
