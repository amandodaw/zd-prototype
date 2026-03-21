class_name AISystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		check_job(delta, entity)

func check_job(delta : float, entity : Entity):

	var ai_comp : AIComponent = entity.get_component(AIComponent)
	var city_comp : CityComponent = ai_comp.city_comp
	var pos : PositionComponent = entity.get_component(PositionComponent)
	var tar : TargetComponent = entity.get_component(TargetComponent)
	var plan : PlanComponent = entity.get_component(PlanComponent)
	if  ai_comp.check_job_count >= ai_comp.check_job_timer:
		ai_comp.check_job_count = 0
		if ai_comp.current_job != city_comp.Tasks.IDLE and city_comp.tasks[ai_comp.current_job]:
			return
		if city_comp.tasks[city_comp.Tasks.BUILD]:
			#Si ya tiene build_order y no tiene plan, ejecutarla
			if has_build_order(entity, city_comp.build_orders):
				if plan.plan.is_empty():
					plan.plan.append(MoveAction.new())
					plan.plan.append(BuildAction.new())
					return
			#Si no tiene y hay disponibles, asignar trabajo para calcular en target_system.
			if is_build_order_available(city_comp.build_orders):
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
	if entity.get_component(TargetComponent).target_pos in entity.city_comp.reserved_tiles:
		entity.city_comp.reserved_tiles.erase(entity.get_component(TargetComponent).target_pos)

func is_adjacent(a: Vector2i, b: Vector2i) -> bool:
	var dx = abs(a.x - b.x)
	var dy = abs(a.y - b.y)
	return max(dx, dy) == 1

func is_build_order_available(build_orders: Dictionary) -> bool:
	for order in build_orders.values():
		if order.state == BuildOrderComponent.State.FREE:
			return true
	return false

func has_build_order(entity: Entity, build_orders: Dictionary) -> bool:
	var target_comp : TargetComponent = entity.get_component(TargetComponent)
	if target_comp.target_pos in build_orders.keys():
		return true
	return false
