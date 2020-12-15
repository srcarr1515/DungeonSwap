extends Node2D
var slot_index = {}
var selected_slot = 0
var swap_in_progress = false
var assigned_char_slot = {4: 1, 5: 2, 6: 3}
var cur_char_slot = assigned_char_slot
signal update_char_slots

func _ready():
	init_slots()

func get_battle_role(_char, slot, char_slots):
	if char_slots.min() < slot.slot_num && char_slots.max() > slot.slot_num:
		## You are the middle slot!
		_char.battle_role = "support"
	else:
		_char.battle_role = "offense"


func init_slots():
	var char_slots = assigned_char_slot.keys()
	## loop through all slots...
	for slot in get_children():
		slot_index[slot.slot_num] = slot
		## if the slot number matches the slot assigned to the character...
		if assigned_char_slot.keys().has(slot.slot_num):
			var _char = playerVar.put_party_member(assigned_char_slot[slot.slot_num])
			playerVar.party_chars[_char.party_slot] = _char
			add_child(_char)
			_char.global_position = slot.global_position
			_char.slot_assign = slot.slot_num
			if char_slots.min() == slot.slot_num:
				_char.toggle_flip(true)
			get_battle_role(_char, slot, char_slots)
			slot.is_clickable = true
		
#		if char_slots.has(slot.slot_num):
#			var _char = playerVar.put_char_actor(playerVar.cur_party[assigned_char_slot[slot.slot_num]])
#			add_child(_char)
#			_char.global_position = slot.global_position
#			_char.slot_assign = slot.slot_num
#			if char_slots.min() == slot.slot_num:
#				_char.toggle_flip(true)
#			get_battle_role(_char, slot, char_slots)
#			slot.is_clickable = true
		if slot.onload_obj != null:
			slot.add_child(slot.onload_obj.instance())

func swap_slot_objects(old_slot, new_slot, assigned_obj):
	swap_in_progress = true
	var from_slot = slot_index[old_slot]
	var to_slot = slot_index[new_slot]
	var p_char_from = []
	var p_char_to = []
	var swap_anim_complete = false
	var char_slots = assigned_char_slot.keys()
	
	## Get characters to swap!
	var p_chars =  get_tree().get_nodes_in_group("player_char")
	for cha in p_chars:
		if cha.slot_assign == old_slot:
			p_char_from.push_front(cha)
		elif cha.slot_assign == new_slot:
			p_char_to.push_front(cha)
#	for c in from_slot.get_children():
#		if c.is_in_group("player_char"):
#			p_char_from.push_front(c)
#	for c in to_slot.get_children():
#		if c.is_in_group("player_char"):
#			p_char_to.push_front(c)
	if p_char_from.size() > 0 && p_char_to.size() > 0:
		swap_anim(p_char_from.front(), p_char_to.front(), to_slot, from_slot)
		yield(p_char_from.front().tween, "tween_completed")
		p_char_from.front().state.state_event({"event": "idle"})
		p_char_to.front().state.state_event({"event": "idle"})
		p_char_from.front().detect.target = null
		p_char_to.front().detect.target = null
		p_char_from.front().detect.check_nearby_entities('enemy')
		p_char_to.front().detect.check_nearby_entities('enemy')
		get_battle_role(p_char_to.front(), from_slot, char_slots)
		get_battle_role(p_char_from.front(), to_slot, char_slots)
		
#	if p_char_from.size() > 0:
#		if !swap_anim_complete:
#			swap_anim(p_char_from.front(), p_char_to.front(), to_slot, from_slot)
#			yield(p_char_from.front().tween, "tween_completed")
#			p_char_from.front().state.state_event({"event": "idle"})
##			yield(p_char_to.front().tween, "tween_completed")
##			p_char_to.front().state.state_event({"event": "idle"})
##		var new_obj = p_char_from.front().duplicate()
##		new_obj.position = Vector2.ZERO
##		new_obj.char_index = p_char_from.front().char_index
##		to_slot.add_child(new_obj)
##		p_char_from.front().queue_free()
#		get_battle_role(p_char_from.front(), to_slot, char_slots)
#	if p_char_to.size() > 0:
#		if !swap_anim_complete:
#			swap_anim(p_char_from.front(), p_char_to.front(), to_slot, from_slot)
#			yield(p_char_to.front().tween, "tween_completed")
#			p_char_to.front().state.state_event({"event": "idle"})
#			print(p_char_to.front().state.current)
			############
#		var new_obj = p_char_to.front().duplicate()
#		new_obj.position = Vector2.ZERO
#		new_obj.char_index = p_char_to.front().char_index
#		from_slot.add_child(new_obj)
#		p_char_to.front().queue_free()
			#####################
#		get_battle_role(p_char_to.front(), from_slot, char_slots)
	swap_in_progress = false

func swap_anim(from_obj, to_obj, from_target, to_target):
	var char_slots = cur_char_slot.keys()
#	EventController.emit_signal("char_state_event", from_obj, {"event": "swap"})
	from_obj.state.state_event({"event": "walk"})
	to_obj.state.state_event({"event": "walk"})
	cur_char_slot[to_target.slot_num] = to_obj.party_slot
	cur_char_slot[from_target.slot_num] = from_obj.party_slot
	from_obj.slot_assign = from_target.slot_num
	to_obj.slot_assign = to_target.slot_num
	if from_obj != null:
		from_obj.move_to(Vector2(from_target.position.x, from_obj.global_position.y))
	if to_obj != null:
		to_obj.move_to(Vector2(to_target.position.x, to_obj.global_position.y))
	emit_signal("update_char_slots")

