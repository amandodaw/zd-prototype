class_name PlannerSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		if !entity.has_component(PlanComponent):
			continue
		var ai_comp : AIComponent = entity.get_component(AIComponent)
		var city_comp : CityComponent = ai_comp.city_comp
		var pos : PositionComponent = entity.get_component(PositionComponent)
		var target_comp : TargetComponent = entity.get_component(TargetComponent)
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		
		var new_plan : Array[Action] = []

		match ai_comp.current_job:

			CityComponent.Tasks.BUILD:
				if plan_comp.needs_replan:
					new_plan.append(MoveAction.new())
					new_plan.append(BuildAction.new())
					set_new_plan(entity, new_plan)

			CityComponent.Tasks.MAKE:
				pass

			CityComponent.Tasks.GATHER_RESOURCES:
				if plan_comp.needs_replan:
					new_plan.append(MoveAction.new())
					new_plan.append(GatherAction.new())
					set_new_plan(entity, new_plan)

			CityComponent.Tasks.IDLE:
				if plan_comp.needs_replan:
					new_plan.append(WaitAction.new())
					new_plan.append(MoveAction.new())
					set_new_plan(entity, new_plan)

			CityComponent.Tasks.ATTACK:
				if plan_comp.needs_replan:
					new_plan.append(MoveAction.new())
					new_plan.append(AttackAction.new())
					set_new_plan(entity, new_plan)
		


func set_new_plan(entity, new_plan):

	var plan_comp : PlanComponent = entity.get_component(PlanComponent)
	var path_comp : PathComponent = entity.get_component(PathComponent)

	if plan_comp.current_action != null:
		plan_comp.current_action.on_cancel(entity)

	plan_comp.plan = new_plan
	plan_comp.current_action = null
	
	plan_comp.needs_replan = false
	path_comp.needs_repath = true
	
