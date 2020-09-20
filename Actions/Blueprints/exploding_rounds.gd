extends Node
## blueprints will have an id attribute, but it will be added dynamically (so it can be unique)
var blueprint = [
	{"args": {"action" : "spawn_action", "action_object": "Bullet", "start_position": Vector2(96, 100), "target": Vector2(5, 0)}, "transition_cue": [true]},
	{"args": {"action" : "move_action", "target_pos": Vector2.ZERO}, "transition_cue": [true]},
	{"args": {"action" : "spawn_action", "action_object": "Explosion", "start_position": "event_location", "emitter": true, "call": [{"func": "set_modulate", "params": [Color(1.1,0.71,0.15,0.83)]}, {"func": "set_scale", "params": [Vector2(0.6,0.5)]}]}, "transition_cue": ["on_destroyed"]}
]

## transition_cues:
## true <-- means there isn't a cue required to advance to.
# on_move_complete{"args": {"action" : "spawn_action", "action_object": "Smoke", "start_position": "event_location", "emitter": true}, "transition_cue": ["on_spawn_action"]}
## on_destroyed

