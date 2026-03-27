class_name AISystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		if !entity.has_component(AIComponent):
			continue
		match entity.entity_type:
			Entity.Entity_type.HUMAN:
				check_job(delta, entity, entities)
			Entity.Entity_type.ZOMBIE:
				var ai_comp : AIComponent = entity.get_component(AIComponent)
				if check_target(entities, Entity.Entity_type.HUMAN):
					ai_comp.current_job = CityComponent.Tasks.ATTACK

func check_job(delta : float, entity : Entity, entities : Array[Entity]):
	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	if  ai_comp.check_job_count >= ai_comp.check_job_timer:
		ai_comp.check_job_count = 0
		
		if ai_comp.current_job != city_comp.Tasks.IDLE and city_comp.tasks[ai_comp.current_job]:
			return

		if city_comp.tasks[CityComponent.Tasks.ATTACK]:
			if check_target(entities, Entity.Entity_type.ZOMBIE):
				ai_comp.current_job = city_comp.Tasks.ATTACK
				return

		if city_comp.tasks[city_comp.Tasks.BUILD] and !city_comp.build_orders.is_empty():
			if has_build_order(entity, city_comp.build_orders):
				ai_comp.current_job = city_comp.Tasks.BUILD
				return

			if is_build_order_available(entity, city_comp.build_orders):
				ai_comp.current_job = city_comp.Tasks.BUILD
				return

		if city_comp.tasks[city_comp.Tasks.MAKE] and !city_comp.make_orders.is_empty():
			ai_comp.current_job = city_comp.Tasks.MAKE
			return

		if city_comp.tasks[CityComponent.Tasks.GATHER_RESOURCES]:
			if check_target(entities, Entity.Entity_type.RESOURCE):
				ai_comp.current_job = city_comp.Tasks.GATHER_RESOURCES
				return

		ai_comp.current_job = CityComponent.Tasks.IDLE
		#reset_job(entity)
		return
	ai_comp.check_job_count += delta

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

func check_target(entities : Array[Entity], target_type : Entity.Entity_type) -> bool:

	for posible_target in entities:
		if posible_target.entity_type == target_type:
			return true
	return false
