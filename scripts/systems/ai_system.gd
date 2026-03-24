class_name AISystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		if !entity.has_component(AIComponent):
			continue
		match entity.entity_type:
			Entity.Entity_type.HUMAN:
				check_job(delta, entity, entities)
			Entity.Entity_type.ZOMBIE:
				check_target(delta, entity, entities, Entity.Entity_type.HUMAN)

func check_job(delta : float, entity : Entity, entities : Array[Entity]):
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	var plan : PlanComponent = entity.get_component(PlanComponent)
	if  ai_comp.check_job_count >= ai_comp.check_job_timer:
		ai_comp.check_job_count = 0
		
		if ai_comp.current_job != city_comp.Tasks.IDLE and city_comp.tasks[ai_comp.current_job]:
			return

		if city_comp.tasks[CityComponent.Tasks.ATTACK]:
			if check_target(delta, entity, entities, Entity.Entity_type.ZOMBIE):
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

	target_comp.target_pos = GridUtils.INVALID
	ai_comp.current_job = CityComponent.Tasks.IDLE

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

func check_target(delta : float, entity : Entity, entities : Array[Entity], target_type : Entity.Entity_type) -> bool:
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	
	for posible_target in entities:
		if posible_target.entity_type == target_type:
			ai_comp.current_job = CityComponent.Tasks.ATTACK
			target_comp.target_type = target_type
			return true
	ai_comp.current_job = CityComponent.Tasks.IDLE
	return false
	
