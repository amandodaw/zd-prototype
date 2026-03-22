class_name TargetSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		var ai_comp : AIComponent = entity.get_component(AIComponent)
		var target_comp : TargetComponent = entity.get_component(TargetComponent)
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		match ai_comp.current_job:
			CityComponent.Tasks.GATHER_RESOURCES:
				pass
			CityComponent.Tasks.BUILD:
				if plan_comp.current_action == null:
					if !take_build_action(entity):
						ai_comp.current_job = CityComponent.Tasks.IDLE
			CityComponent.Tasks.MAKE:
				pass

func take_build_action(entity : Entity) -> bool:
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	for build_order_pos in city_comp.build_orders.keys():
		var build_order : BuildOrderComponent = city_comp.build_orders.get(build_order_pos)
		if build_order.state == BuildOrderComponent.State.FREE:
			if city_comp.wood_amount < build_order.cost:
				print("not enough wood")
				return false
			city_comp.wood_amount -= build_order.cost
			
			build_order.state = BuildOrderComponent.State.RESERVED
			build_order.worker = entity
			
			entity.get_component(TargetComponent).target_pos = build_order_pos
			entity.get_component(TargetComponent).adyacent_target_pos = entity.choose_adjacent(build_order_pos)
			
			#city_comp.build_orders.erase(build_order_pos)
			reserve_target(entity)
			#set_astar_path()
			return true
			
	print("no build order to take")
	return false



func reserve_target(entity : Entity) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	city_comp.reserved_tiles.set(entity.get_component(TargetComponent).target_pos, true)

func release_target(entity : Entity) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	if entity.get_component(TargetComponent).target_pos in city_comp.reserved_tiles:
		city_comp.reserved_tiles.erase(entity.get_component(TargetComponent).target_pos)
