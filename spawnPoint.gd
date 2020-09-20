extends Position2D

onready var timer = $Timer
var formation = ["Skeleton_Warrior", "Skeleton_Warrior", "Skeleton_Warrior"]
var timer_amt = 3
export var deployment_group = "left_side_enemy"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	reset_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reset_timer():
	timer_amt = rand_range(2.5,3.5)
	timer.start(timer_amt)

func _on_Timer_timeout():
	if formation.size() > 0:
		spawnEnemy(formation.front())
		formation.pop_front()
	else:
		## Request another enemy formation! (signal to formation controller)
		print("No More Enemies")

func spawnEnemy(enemy_name):
	var actor_path = "res://Actors/Enemy/{enemy_name}.tscn"
	var enemy = load(actor_path.format({"enemy_name": enemy_name})).instance()
	enemy.add_to_group(deployment_group)
	add_child(enemy)