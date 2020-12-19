extends Node

var char_defaults = {
	"Gunslinger": {
		"weapon": 0
	},
	"Templar": {
		"weapon": 1
	},
	"Arcanist": {
		"weapon": 2
	}
}
var char_list = [
	{"char_class": "Arcanist"}, 
	{"char_class": "Templar"}, 
	{"char_class": "Gunslinger"}
]
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

var item_dict = [
	{'name': 'gun', 'atk_power': 1, 'anim': 'Bullet'},
	{'name': 'broadsword', 'atk_power': 3, 'anim': null},
	{'name': 'staff', 'atk_power': 2, 'anim': null}
]

var skill_dict = {
	"holy_bolt": {'skill_name': "holy_bolt", "cooldown": 10, "atk_power": 5},
	"faith_healing": {'skill_name': "faith_healing", "cooldown": 5, "atk_power": 5},
	"resurrect": {'skill_name': "resurrect", "cooldown": 30, "atk_power": 5},
	"runic_wall": {'skill_name': "runic_wall", "cooldown": 20, "atk_power": 5},
	"energy_nova": {'skill_name': "energy_nova", "cooldown": 10, "atk_power": 5},
	"eldritch_blitz": {'skill_name': "eldritch_blitz", "cooldown": 30, "atk_power": 5},
	"dynamite": {'skill_name': "dynamite", "cooldown": 10, "atk_power": 15},
	"snare": {'skill_name': "snare", "cooldown": 10, "atk_power": 10},
	"sharpshoot": {'skill_name': "sharpshoot", "cooldown": 5, "atk_power": 4}
}

var item_bank = {}
var inventory = []

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
	## Temporary Add Skill End
	
	
	for ch in char_list:
		## Was having issues with .duplicate() ## Should probably be aware of that.
		ch["equipment"] = {
			'weapon': [],
			'armor': [],
			'accessory': []
		}
		if ch["char_class"] in char_defaults.keys():
			for eq in ch["equipment"].keys():
				## Set default equipment
				if eq in char_defaults[ch["char_class"]].keys():
					var equip_slot = ch["equipment"][eq]
					var item_id = char_defaults[ch["char_class"]][eq]
					add_item(item_id, equip_slot)
	
	for slot in cur_skills.keys():
		## TODO: Need to handle the edge case where we have 1/none skills equipped
		cur_skills[slot] = equipped_skills[cur_party[slot]]
	
func add_skill(skill_name, char_id, options=null):
	if skill_name in skill_dict.keys():
		var skill_details = skill_dict[skill_name]
		if options == null:
			pass ## Thinking about modifiers such as increased level or other adjustments
		var skill_id = Helpers.random(skill_list.keys())
#		skill_list[skill_id] = {"skill_name": skill_name, "char_id": char_id}
		skill_list[skill_id] = skill_details.duplicate()
		skill_list[skill_id]["char_id"] = char_id
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
	return char_list[cur_party[party_slot]] ## returns char DATA object assigned to party slot

func get_party_slot(char_index):
	var p_slot = null
	for party_slot in cur_party.keys():
		if cur_party[party_slot] == char_index:
			p_slot = party_slot
	return p_slot

func put_char_actor(char_index):
	var player_char = load(actor_path.format({"char_class": char_list[char_index].char_class})).instance()
	player_char.char_index = char_index
	var weapon_iid = char_list[char_index]["equipment"]["weapon"].front()
	if weapon_iid != null:
		player_char.atk_anim = item_bank[weapon_iid]["anim"]
		player_char.atk_power = item_bank[weapon_iid]["atk_power"]
	return player_char

func add_item(item_id, zone):
	if item_id < item_dict.size():
		var item_instance = item_dict[item_id]
		var item_instance_id = Helpers.random(item_bank.keys())
		item_bank[item_instance_id] = item_instance.duplicate()
		zone.push_back(item_instance_id)
		return item_instance_id

func move_item(item_iid, from_zone, to_zone):
	var iid_index = from_zone.find(item_iid)
	if iid_index != -1:
		from_zone.erase(item_iid)
		to_zone.push_back(item_iid)

func equip_item_to_char(item_instance_id, equip_slot, char_index):
	## We take a existing item (with an iid) and move it into a slot.
	## If that slot already has something in it, we move that equipped item to the inventory.
	if item_instance_id in inventory && char_index in char_list:
		## For now we are going to assume you only get one item in your equipment slot (we use an array so we have the option to do more later.)
		var cur_equipment = char_list[char_index]["equipment"][equip_slot].front()
		if cur_equipment != null:
			inventory.push_back(cur_equipment)
			char_list[char_index]["equipment"][equip_slot] = []
		if char_list[char_index]["equipment"][equip_slot] == []:
			char_list[char_index]["equipment"][equip_slot].push_front(item_instance_id)

func put_party_member(party_slot):
	var char_index = cur_party[party_slot]
	var player_char = put_char_actor(char_index)
	player_char.party_slot = party_slot
	return player_char

func get_char_instance_by_index(char_index):
	var chars = get_tree().get_nodes_in_group("player_char")
	for ch in chars:
		if ch.char_index == char_index:
			return ch
