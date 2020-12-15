extends Node

var char_list = [{"char_class": "Arcanist"}, {"char_class": "Templar"}, {"char_class": "Gunslinger"}]
## Rather than rely on a lookup hash, we are just going to follow pathing convention!
var actor_path = "res://Actors/Player/{char_class}.tscn" 
var coin = 0
var cur_party = {
	1: 1,
	2: 0,
	3: 2
}
var cur_skills = {
	1: [],
	2: [],
	3: []
}
var party_chars = { ## Gives you actual objects
	1: null,
	2: null,
	3: null,
}

var equipped_skills = {}

var skill_list = {}

func _ready():
	## Temporary Add skill
	add_skill("faith_healing", 1)
	add_skill("resurrect", 1)
	add_skill("holy_bolt", 1)
	add_skill("runic_wall", 0)
	add_skill("energy_nova", 0)
	add_skill("eldritch_blitz", 0)
	add_skill("dynamite", 2)
	add_skill("snare", 2)
	add_skill("sharpshoot", 2)
	for slot in cur_skills.keys():
		cur_skills[slot] = equipped_skills[cur_party[slot]]
	
func add_skill(skill_name, char_id, options=null):
	if options == null:
		pass ## Thinking about modifiers such as increased level or other adjustments
	var skill_id = Helpers.random()
	skill_list[skill_id] = {"skill_name": skill_name, "char_id": char_id}
	## auto-equip skills if none are equipped
	var add_skill = -1
	if equipped_skills.has(char_id):
		add_skill = equipped_skills[char_id].find(null)
	else:
		add_skill = 0
	if add_skill > -1:
		equip_skill(skill_id, add_skill)
	return skill_id

func equip_skill(skill_id, equip_index=0):
	if skill_list.has(skill_id):
		var char_id = skill_list[skill_id]["char_id"]
		if !equipped_skills.has(char_id):
			equipped_skills[char_id] = [null,null,null]
		var skill_now = equipped_skills[char_id]
		if skill_now.size() < 4 && equip_index < 3:
			equipped_skills[char_id][equip_index] = skill_id

func get_party_member(party_slot):
	return char_list[cur_party[party_slot]] ## returns char object assigned to party slot

func get_party_slot(char_index):
	var p_slot = null
	for party_slot in cur_party.keys():
		if cur_party[party_slot] == char_index:
			p_slot = party_slot
	return p_slot

func put_char_actor(char_index):
	var player_char = load(actor_path.format({"char_class": char_list[char_index].char_class})).instance()
	player_char.char_index = char_index
	return player_char

func put_party_member(party_slot):
	var char_index = cur_party[party_slot]
	var player_char = put_char_actor(char_index)
	player_char.party_slot = party_slot
	return player_char
