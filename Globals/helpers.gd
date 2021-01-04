extends Node

func toggle_flip(sprite, flip):
	if flip == null:
		flip = sprite.is_flipped_h()
	if sprite.is_flipped_h() != flip:
		if sprite.offset != Vector2.ZERO:
			sprite.offset *= -1
	if flip:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func random(exclude_list=null):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_num = randi()
	## Check random number againt list of ids you want to exclude. (to ensure uniqueness)
	if exclude_list != null:
		while random_num in exclude_list:
			random_num = randi()
	return random_num

func pick_nearest(group, _position):
	var targets = get_tree().get_nodes_in_group(group)
	var nearest_target = targets[0]
	for t in targets:
		if t.global_position.distance_to(_position) < nearest_target.global_position.distance_to(_position):
			nearest_target = t
	return nearest_target

func choose(list, how_many=1):
	var which_index = int(rand_range(0, list.size()))
	return list[which_index]
