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
		if city_comp.tasks[city_comp.Tasks.BUILD] and !city_comp.build_orders.is_empty():
			plan.plan.clear()
			plan.plan.append(MoveAction.new())
			#ai_comp.current_job = city_comp.Tasks.BUILD
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
