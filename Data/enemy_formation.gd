#	var enemy_formation = load("res://Data/enemy_formation.gd").new()
#	enemy_formation.list
extends Node

var list = [
	["Skeleton_Warrior", "Wolf"],
	["Skeleton_Warrior", {"delay": 2.5, "enemy": "Skeleton_Warrior", "spawn_side": "both"}],
	[
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "right", "enemy": "Skeleton_Archer"},
		{"delay": 2.5},
		{"spawn_side": "left", "enemy": "Skeleton_Archer"},
		{"spawn_side": "right", "enemy": "Skeleton_Warrior"},
	],
	[
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "right", "enemy": "Skeleton_Archer"},
		{"spawn_side": "both", "delay": 2.5, "enemy": "Wolf"},
		"Skeleton_Warrior"
	],
	[
		"Wolf",
		{"spawn_side": "both", "delay": 2.5, "enemy": "Skeleton_Archer"}
	],
	[
		"Skeleton_Warrior",
		{"spawn_side": "both", "delay": 2.5, "enemy": "Skeleton_Archer"},
		{"spawn_side": "both", "delay": 2.5, "enemy": "Wolf"}
	],
	[
		{"spawn_side": "right", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "right", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "right", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "right", "enemy": "Skeleton_Warrior"},
		{"delay": 2.5},
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"},
		{"spawn_side": "left", "enemy": "Skeleton_Warrior"}
	],
	[
		{"spawn_side": "right", "enemy": "Wolf"},
		{"spawn_side": "left", "enemy": "Skeleton_Archer"},
		{"spawn_side": "left", "enemy": "Wolf", "delay": 3},
		{"spawn_side": "right", "enemy": "Skeleton_Archer"},
	]
]
