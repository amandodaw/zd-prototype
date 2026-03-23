class_name AISystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		match entity.entity_type:
			Entity.Entity_type.HUMAN:
				check_job(delta, entity)
			Entity.Entity_type.ZOMBIE:
				find_human(delta, entity, entities)

func check_job(delta : float, entity : Entity):
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	var plan : PlanComponent = entity.get_component(PlanComponent)
	if  ai_comp.check_job_count >= ai_comp.check_job_timer:
		ai_comp.check_job_count = 0
		
		#if ai_comp.current_job != city_comp.Tasks.IDLE and city_comp.tasks[ai_comp.current_job]:
		if ai_comp.current_job != CityComponent.Tasks.IDLE:
			return

		if city_comp.tasks[city_comp.Tasks.BUILD] and !city_comp.build_orders.is_empty():
			if has_build_order(entity, city_comp.build_orders):
				return

			if is_build_order_available(entity, city_comp.build_orders):
				plan.plan.clear()
				ai_comp.current_job = city_comp.Tasks.BUILD
				return

		if city_comp.tasks[city_comp.Tasks.MAKE] and !city_comp.make_orders.is_empty():
			ai_comp.current_job = city_comp.Tasks.MAKE
			return

		if city_comp.tasks[CityComponent.Tasks.GATHER_RESOURCES]:
			ai_comp.current_job = city_comp.Tasks.GATHER_RESOURCES
			return

		reset_job(entity)
		return
	ai_comp.check_job_count += delta

func reset_job(entity : Entity) ->void:
	var ai_comp = entity.get_component(AIComponent)
	var target_comp = entity.get_component(TargetComponent)
	var city_comp = entity.get_component(CityComponent)
	release_target(entity)
	target_comp.target_pos = GridUtils.INVALID
	ai_comp.current_job = CityComponent.Tasks.IDLE

func release_target(entity : Entity) -> void:
	var city_comp = entity.get_component(AIComponent).city_comp
	if entity.get_component(TargetComponent).target_pos in city_comp.reserved_tiles:
		city_comp.reserved_tiles.erase(entity.get_component(TargetComponent).target_pos)

func is_build_order_available(entity : Entity, build_orders: Dictionary) -> bool:
	var city_comp : CityComponent = entity.get_component(AIComponent).city_comp
	for order in build_orders.values():
		if order.state == BuildOrderComponent.State.FREE and city_comp.wood_amount>=order.cost:
			return true
		
	return false

func has_build_order(entity: Entity, build_orders: Dictionary) -> bool:
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	if target_comp.target_pos in build_orders.keys():
		return true
	return false

func find_human(delta : float, entity : Entity, entities : Array[Entity]) -> void:
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	
	for posible_target in entities:
		if posible_target.entity_type == Entity.Entity_type.HUMAN:
			ai_comp.current_job = CityComponent.Tasks.ATTACK
			return
	ai_comp.current_job = CityComponent.Tasks.IDLE
	
