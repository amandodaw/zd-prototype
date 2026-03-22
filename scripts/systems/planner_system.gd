class_name PlannerSystem

func update(delta : float, entities :  Array[Entity]):
	for entity in entities:
		var ai_comp : AIComponent = entity.get_component(AIComponent)
		var city_comp : CityComponent = ai_comp.city_comp
		var pos : PositionComponent = entity.get_component(PositionComponent)
		var target_comp : TargetComponent = entity.get_component(TargetComponent)
		var plan_comp : PlanComponent = entity.get_component(PlanComponent)
		match ai_comp.current_job:

			CityComponent.Tasks.BUILD:
				if plan_comp.current_action == null:
					plan_comp.plan.append(MoveAction.new())
					plan_comp.plan.append(BuildAction.new())

			CityComponent.Tasks.MAKE:
				pass

			CityComponent.Tasks.GATHER_RESOURCES:
				if plan_comp.current_action == null and plan_comp.plan.is_empty():
					plan_comp.plan.append(MoveAction.new())
					plan_comp.plan.append(GatherAction.new())

			CityComponent.Tasks.IDLE:
				if plan_comp.current_action == null and plan_comp.plan.is_empty():
					plan_comp.plan.append(WaitAction.new())
					plan_comp.plan.append(MoveAction.new())
					print("wander action queued")

			CityComponent.Tasks.ATTACK:
				if plan_comp.current_action == null and plan_comp.plan.is_empty():
					plan_comp.plan.append(MoveAction.new())
					plan_comp.plan.append(AttackAction.new())
