class_name TargetSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		pass

func take_build_action(entity : Entity) -> bool:
	var city_comp = entity.get_component(AIComponent).city_comp
	for build_order in city_comp.build_orders.keys():
		if build_order not in city_comp.reserved_tiles:
			if city_comp.wood_amount < wall_cost:
				print("not enough wood")
				return false
			city_comp.wood_amount -= wall_cost
			get_component(TargetComponent).target_pos = build_order
			get_component(TargetComponent).adyacent_target_pos = choose_adjacent(build_order)
			reserve_target()
			set_astar_path()
			return true
			
	print("no build order to take")
	return false
